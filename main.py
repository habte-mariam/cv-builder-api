import streamlit as st
from supabase import create_client, Client
from pdf_generator import CVGenerator
import base64
from streamlit_option_menu import option_menu 
import google.generativeai as genai
from constants import (
    JOB_CATEGORIES, SKILLS_DATABASE, UNIVERSITIES, 
    DEGREE_TYPES, FIELDS_OF_STUDY, DEREJA_CERTIFICATES, 
    CERTIFICATE_NAMES, ISSUING_ORGANIZATIONS
)

# --- Supabase & Gemini API Key Setup ---
SUPABASE_URL = st.secrets["SUPABASE_URL"]
SUPABASE_KEY = st.secrets["SUPABASE_KEY"]
GEMINI_API_KEY = st.secrets["GEMINI_API_KEY"]

# --- Gemini Configuration ---
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-3-flash-preview')

def get_ai_suggestion(prompt):
    try:
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        return f"AI Error: {e}"

# --- Supabase Setup ---
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
st.set_page_config(page_title="CV Maker Pro", layout="wide")

# --- 1. Session State Initialization ---
# ገጹ መጀመሪያ ሲከፈት ዳሽቦርድ ላይ እንዲሆን እና ባዶ ዳታ እንዲይዝ
if "page" not in st.session_state:
    st.session_state.page = "Dashboard"

if "ui" not in st.session_state:
    st.session_state.ui = {} 

if "current_pdf" not in st.session_state:
    st.session_state.current_pdf = None

# --- 2. Sidebar Layout ---
with st.sidebar:
    st.title("🚀 CV Maker Pro")
    st.divider()

    # ገጹን ለመቀየር option_menu መጠቀም (ዘመናዊ ስለሆነ)
    # index የሚወሰነው በ session_state.page ነው (ከዳሽቦርድ ወደ ኤዲት ለመሸጋገር ይረዳል)
    page_selection = option_menu(
        menu_title="Menu",
        options=["Dashboard", "Create/Edit CV"],
        icons=["grid", "pencil-square"],
        menu_icon="cast",
        default_index=0 if st.session_state.page == "Dashboard" else 1,
    )
    
    # ተጠቃሚው የመረጠውን ገጽ በ session_state ውስጥ መመዝገብ
    st.session_state.page = page_selection
    
    st.divider()

    # 2. Design Selection (በExpander ተሰብስቦ)
    with st.expander("🎨 Appearance & Theme", expanded=True):
        design = st.selectbox(
            "Choose Template", 
            ["creative", "modern", "minimal", "executive", "classic", "corporate", "bold", "elegant", "professional", "compact"],
            help="Select the visual layout of your CV"
        )
        theme_hex = st.color_picker("Brand Color", "#2C3E50")
        font_choice = st.selectbox("Font Family", ["Arial", "Courier", "Helvetica", "Times"])

    # 3. Layout Control
    with st.expander("🏗️ CV Structure"):
        st.write("Drag and reorder sections:")
        section_order = st.multiselect(
            "Display Sections",
            ["Summary", "Experience", "Education", "Skills", "Certificates", "References"],
            default=["Summary", "Experience", "Education", "Skills", "Certificates", "References"]
        )

    st.divider()
    st.caption("v2.0 | Powered by HabTech")

# --- 3. Content Logic (ከገጽ ምርጫው ጋር የተያያዘ) ---
if st.session_state.page == "Dashboard":
    st.title("📊 User Dashboard")
    
    with st.container(border=True):
        st.subheader("🔍 Find Your CV")
        st.write("Enter your email address to retrieve and manage your saved resumes.")
        
        col1, col2 = st.columns([4, 1]) 
        with col1:
            email_q = st.text_input("Email Address", placeholder="example@email.com", label_visibility="collapsed")
        with col2:
            search_clicked = st.button("Search Now 🔎", use_container_width=True, type="primary")

    if search_clicked or (email_q and not search_clicked):
        if email_q:
            with st.spinner("Fetching your records..."):
                res = supabase.table("profiles").select("*, education(*), experience(*), skills(*), languages(*), certificates(*), user_references(*)").eq("email", email_q).execute()
                
                if res.data:
                    st.divider()
                    for user in res.data:
                        with st.container(border=True):
                            c1, c2 = st.columns([3, 1])
                            with c1:
                                st.markdown(f"### 📄 {user['first_name']} {user['last_name']}")
                                st.caption(f"🎯 **Role:** {user.get('job_title', 'Not Specified')} | 📍 {user.get('address', '')}")
                            
                            with c2:
                                st.write("") 
                                if st.button("📝 Edit CV", key=f"edit_{user['id']}", use_container_width=True):
                                    # እዚህ ጋር ነው ለውጡ ያለው!
                                    st.session_state.ui = user
                                    st.session_state.page = "Create/Edit CV" # ገጹን ቀይር
                                    st.rerun() # ወዲያውኑ ገጹን አድስ
                else:
                    st.warning("⚠️ No records found.")

elif st.session_state.page == "Create/Edit CV":
    ui = st.session_state.get("ui", {})
    st.title("📝 CV Builder")
    
    if not ui:
        st.info("💡 Please start by loading a CV from the Dashboard or enter your details below.")
    
    # 1. Profile Photo (ከፎርም ውጭ መሆን አለበት)
    st.subheader("Profile Photo")
    uploaded_file = st.file_uploader("Upload Profile Photo", type=["jpg", "jpeg", "png"])
    profile_pic_base64 = ui.get("profile_pic", None)
    if uploaded_file:
        bytes_data = uploaded_file.getvalue()
        profile_pic_base64 = base64.b64encode(bytes_data).decode("utf-8")
        st.image(bytes_data, width=100)

    # 2. ዋናው ፎርም እዚህ ይጀምራል
    with st.form("cv_universal_form"):
        # ታቦቹ በፎርሙ ውስጥ መፈጠር አለባቸው
        tabs = st.tabs(["👤 Profile", "🎓 Education", "💼 Experience", "🎖 Qualifications", "🛠 Skills", "🚀 Generate"])
        
        # --- Profile Tab ---
        with tabs[0]:
            st.subheader("Personal Information")
            c1, c2 = st.columns(2)
            fn = c1.text_input("First Name", ui.get("first_name", ""))
            ln = c2.text_input("Last Name", ui.get("last_name", ""))
            em = st.text_input("Email", ui.get("email", ""))
            
            category = st.selectbox("Department", options=list(JOB_CATEGORIES.keys()))
            jt = st.selectbox("Job Title", options=JOB_CATEGORIES[category] + ["Other"])
            
            ph = c1.text_input("Phone", ui.get("phone", ""))
            ph2 = c2.text_input("Secondary Phone", ui.get("phone2", ""))
            adr = st.text_input("Address", ui.get("address", ""))
            
            from datetime import date
            today = date.today()
            birth_date = st.date_input("Select Birth Date", value=date(today.year - 25, today.month, today.day))
            age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
            st.info(f"Age: **{age}**")
            
            gen = c2.selectbox("Gender", ["Male", "Female"], index=0 if ui.get("gender")=="Male" else 1)
            summ = st.text_area("Summary", ui.get("summary", ""), height=120)

        # --- Education Tab ---
        with tabs[1]:
            st.subheader("Academic Background")
            edu_list = ui.get('education', [])
            ed = edu_list[0] if isinstance(edu_list, list) and len(edu_list) > 0 else {}
            school_levels = ["Grade 1-8", "Grade 9-10", "Grade 11-12"]
            current_deg = ed.get('degree', "Bachelor's Degree")
            deg = st.selectbox("Level of Education", options=DEGREE_TYPES, 
                               index=DEGREE_TYPES.index(current_deg) if current_deg in DEGREE_TYPES else 0)

            if deg in school_levels:
                sch = st.text_input("School Name", ed.get('school', ""))
                gy = st.number_input("Year of Completion", 1990, 2030, int(ed.get('grad_year', 2024)))
                fld, cgpa, proj = "General Education", "N/A", ""
            else:
                sch_choice = st.selectbox("University", options=UNIVERSITIES)
                sch = st.text_input("Manual School Name", ed.get('school', "")) if sch_choice == "Other" else sch_choice
                fld_choice = st.selectbox("Field of Study", options=FIELDS_OF_STUDY)
                fld = st.text_input("Specify Field", ed.get('field', "")) if fld_choice == "Other" else fld_choice
                cgpa = st.text_input("CGPA", str(ed.get('cgpa', '0.0')))
                proj = st.text_area("Final Project/Thesis", ed.get('project', ""))
                gy = st.number_input("Year of Graduation", 1990, 2030, int(ed.get('grad_year', 2024)))

        # --- Experience Tab ---
        with tabs[2]:
            st.subheader("Work History")
            exp_list = ui.get('experience', [])
            ex = exp_list[0] if isinstance(exp_list, list) and len(exp_list) > 0 else {}
            cn = st.text_input("Company Name", ex.get('company_name', ""))
            ex_jt = st.text_input("Position", ex.get('job_title', ""))
            dur = st.number_input("Years of Experience", 0, 40, 0)
            desc = st.text_area("Description", ex.get('job_description', ""))
            ach = st.text_area("Key Achievements", ex.get('achievements', ""))

        # --- Qualifications Tab ---
        with tabs[3]:
            col_a, col_b = st.columns(2)
            with col_a:
                st.subheader("Certificates")
                c_org = st.selectbox("Issuing Organization", ISSUING_ORGANIZATIONS)
                c_nm = st.selectbox("Certificate Name", CERTIFICATE_NAMES)
                c_yr = st.number_input("Year", 2000, 2030, 2025)
            with col_b:
                st.subheader("References")
                ref_list = ui.get('user_references', [])
                rf = ref_list[0] if isinstance(ref_list, list) and len(ref_list) > 0 else {}
                r_nm = st.text_input("Ref Full Name", rf.get('name', ""))
                r_jb = st.text_input("Ref Job & Company", rf.get('job', ""))
                r_ph = st.text_input("Ref Phone", rf.get('phone', ""))

        # --- Skills Tab (አሁን በትክክለኛው ቦታ ላይ ነው) ---
        with tabs[4]:
            st.subheader("🛠 Professional Skills")
            if 'temp_skills' not in st.session_state:
                existing_skills = [s['name'] for s in ui.get('skills', [])] if isinstance(ui.get('skills'), list) else []
                st.session_state.temp_skills = set(existing_skills)

            skill_categories = list(SKILLS_DATABASE.keys())
            selected_cat = st.selectbox("📂 Choose Category", options=skill_categories, key="skill_cat_select")
            
            category_options = SKILLS_DATABASE.get(selected_cat, [])
            cols = st.columns(3)
            for i, skill in enumerate(category_options):
                is_checked = skill in st.session_state.temp_skills
                with cols[i % 3]:
                    if st.checkbox(skill, value=is_checked, key=f"chk_{skill}"):
                        st.session_state.temp_skills.add(skill)
                    else:
                        if skill in st.session_state.temp_skills:
                            st.session_state.temp_skills.remove(skill)
            
            st.info(f"Selected: {', '.join(sorted(st.session_state.temp_skills))}")

        # --- Generate Tab ---
        with tabs[5]:
            st.info("Ensure all data is correct before proceeding.")
            submit = st.form_submit_button("🚀 Save Data & Generate Full Preview", use_container_width=True)

    # 3. ፎርሙ ሲላክ የሚሰራ ሎጂክ (ከፎርሙ ብሎክ ውጭ)
    if submit:
        # ... (የቅድሙ የዳታ ሴቭ ሎጂክ እዚህ ይቀጥላል)
        st.success("✅ CV Saved!")
    # --- Logic after form submission (OUTSIDE TABS) ---
    if submit:
        try:
            profile_payload = {
                "profile_pic": profile_pic_base64, "email": em, "first_name": fn, "last_name": ln, 
                "job_title": jt, "phone": ph, "phone2": ph2, "address": adr, "age": int(age),
                "gender": gen, "summary": summ
            }
            res = supabase.table("profiles").upsert(profile_payload, on_conflict="email").execute()
            p_id = res.data[0]['id']

            # Upsert related tables
            supabase.table("education").upsert({"profile_id": p_id, "school": sch, "degree": deg, "field": fld, "grad_year": gy, "cgpa": str(cgpa), "project": proj}, on_conflict="profile_id").execute()
            supabase.table("experience").upsert({"profile_id": p_id, "company_name": cn, "job_title": ex_jt, "duration": f"{dur} Years", "job_description": desc, "achievements": ach}, on_conflict="profile_id").execute()
            
            # Prepare full data for PDF
            full_data = profile_payload
            full_data.update({
                "education": [{"school": sch, "degree": deg, "field": fld, "grad_year": gy, "cgpa": str(cgpa)}],
                "experience": [{"company_name": cn, "job_title": ex_jt, "duration": f"{dur} Years", "job_description": desc, "achievements": ach}],
                "certificates": [{"cert_name": c_nm, "organization": c_org, "year": str(c_yr)}],
                "user_references": [{"name": r_nm, "job": r_jb, "phone": r_ph}],
                "skills": [{"name": s} for s in st.session_state.temp_skills]
            })

            generator = CVGenerator(design=design, custom_theme=theme_hex, font_family=font_choice)
            st.session_state.current_pdf = generator.create_cv(full_data, section_order)
            st.success("✅ CV Generated Successfully!")
            st.rerun() 
        except Exception as e:
            st.error(f"Error: {e}")

    # Display PDF below
    if st.session_state.get("current_pdf"):
        pdf_bytes = bytes(st.session_state.current_pdf)
        base64_pdf = base64.b64encode(pdf_bytes).decode('utf-8')
        pdf_display = f'<iframe src="data:application/pdf;base64,{base64_pdf}" width="100%" height="1000px" style="border-radius:10px;"></iframe>'
        st.markdown(pdf_display, unsafe_allow_html=True)
        st.download_button("📥 Download PDF", data=pdf_bytes, file_name="CV.pdf", mime="application/pdf", use_container_width=True)