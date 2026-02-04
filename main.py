import streamlit as st
from supabase import create_client, Client
from pdf_generator import CVGenerator
import base64
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

# --- Sidebar: Styling & Navigation ---
st.sidebar.title("🎨 CV Styling")
with st.sidebar.container(border=True):
    design = st.sidebar.selectbox("Design Template", 
        ["creative", "modern", "minimal", "executive", "classic", "corporate", "bold", "elegant", "professional", "compact"])
    theme_hex = st.sidebar.color_picker("Theme Color", "#2C3E50")

with st.sidebar.container(border=True):
    font_choice = st.sidebar.selectbox("Font Style", ["Arial", "Courier", "Helvetica", "Times"])
    section_order = st.sidebar.multiselect(
        "Section Order",
        ["Summary", "Experience", "Education", "Skills", "Certificates", "References"],
        default=["Summary", "Experience", "Education", "Skills", "Certificates", "References"]
    )

page = st.sidebar.radio("Navigation", ["Dashboard", "Create/Edit CV"])

if "ui" not in st.session_state:
    st.session_state.ui = {}
if "current_pdf" not in st.session_state:
    st.session_state.current_pdf = None

# --- Dashboard ---
if page == "Dashboard":
    st.title("📊 User Dashboard")
    email_q = st.text_input("Enter your email to load CV")
    if email_q:
        res = supabase.table("profiles").select("*, education(*), experience(*), skills(*), languages(*), certificates(*), user_references(*)").eq("email", email_q).execute()
        if res.data:
            for user in res.data:
                with st.container(border=True):
                    st.subheader(f"📄 {user['first_name']} {user['last_name']}")
                    st.caption(f"Role: {user['job_title']}")
                    if st.button("Edit this CV", key=user['id']):
                        st.session_state.ui = user
                        st.success("Data loaded! Go to 'Create/Edit CV' page.")
        else: st.warning("No records found.")

# --- Create/Edit CV ---
elif page == "Create/Edit CV":
    ui = st.session_state.ui
    st.title("📝 CV Builder")

    # Photo Upload must be OUTSIDE the form to work properly in Streamlit
    st.subheader("Profile Photo")
    uploaded_file = st.file_uploader("Upload Profile Photo", type=["jpg", "jpeg", "png"])
    profile_pic_base64 = ui.get("profile_pic", None)
    if uploaded_file:
        bytes_data = uploaded_file.getvalue()
        profile_pic_base64 = base64.b64encode(bytes_data).decode("utf-8")
        st.image(bytes_data, width=100)

    # Start the Universal Form
    with st.form("cv_universal_form"):
        tabs = st.tabs(["👤 Profile", "🎓 Education", "💼 Experience", "🎖 Qualifications", "🛠 Skills", "🚀 Generate"])
        
        # 1. Profile Tab
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
            
            try:
                raw_age = str(ui.get("age", 25))
            except:
                raw_age = 25
            age = c1.number_input("Age", min_value=18, max_value=60, value=max(18, str(raw_age) if raw_age.isdigit() else 25))
            
            gen = c2.selectbox("Gender", ["Male", "Female"], index=0 if ui.get("gender")=="Male" else 1)
            summ = st.text_area("Summary", ui.get("summary", ""), height=120)

        # 2. Education Tab
        with tabs[1]:
            st.subheader("Academic Background")
            edu_list = ui.get('education', [])
            ed = edu_list[0] if isinstance(edu_list, list) and len(edu_list) > 0 else {}
            school_levels = ["Grade 1-8", "Grade 9-10", "Grade 11-12"]
            
            # 1. Level Selection
            current_deg = ed.get('degree', "Bachelor's Degree")
            deg = st.selectbox("Level of Education", options=DEGREE_TYPES, 
                               index=DEGREE_TYPES.index(current_deg) if current_deg in DEGREE_TYPES else 0)

            # 2. Conditional School Name Input
            if deg in school_levels:
                # ለ 1-12 ተማሪዎች የዩኒቨርሲቲ ምርጫ አያስፈልግም፣ ስም ብቻ ማስገባት
                sch = st.text_input("School Name", ed.get('school', ""))
                fld, cgpa, proj = "General Education", "N/A", ""
            else:
                # ለከፍተኛ ትምህርት የዩኒቨርሲቲ ዝርዝር ማሳየት
                sch_choice = st.selectbox("University", options=UNIVERSITIES)
                sch = st.text_input("Manual School Name", ed.get('school', "")) if sch_choice == "Other" else sch_choice
                
                # ለከፍተኛ ትምህርት ብቻ የሚታዩ (Field, CGPA, Project)
                fld_choice = st.selectbox("Field of Study", options=FIELDS_OF_STUDY)
                fld = st.text_input("Specify Field", ed.get('field', "")) if fld_choice == "Other" else fld_choice
                cgpa = st.text_input("CGPA", str(ed.get('cgpa', '0.0')))
                proj = st.text_area("Final Project/Thesis", ed.get('project', ""))

            # 3. Year of Completion (ሁልጊዜ ይታያል)
            gy = st.number_input("Year of Completion", 1990, 2030, int(ed.get('grad_year', 2024)))

            # Save values to UI state for DB submission
            ui['education_school'] = sch
            ui['education_degree'] = deg
            ui['education_field'] = fld
            ui['education_cgpa'] = cgpa
            ui['education_project'] = proj
            ui['education_year'] = gy

        # 3. Experience Tab
        with tabs[2]:
            st.subheader("Work History")
            exp_list = ui.get('experience', [])
            ex = exp_list[0] if isinstance(exp_list, list) and len(exp_list) > 0 else {}
            cn = st.text_input("Company Name", ex.get('company_name', ""))
            ex_jt = st.text_input("Position", ex.get('job_title', ""))
            
            try:
                raw_dur = int(''.join(filter(str.isdigit, str(ex.get('duration', '0')))))
            except:
                raw_dur = 0
            dur = st.number_input("Years of Experience", 0, 40, raw_dur)
            desc = st.text_area("Description", ex.get('job_description', ""))
            ach = st.text_area("Key Achievements", ex.get('achievements', ""))

        # 4. Qualifications Tab
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

# 5. Skills Tab
        with tabs[4]:
            st.subheader("Skills")
            existing_skills = [s['name'] for s in ui.get('skills', [])] if isinstance(ui.get('skills'), list) else []
            
            all_available_options = sorted(list(set(SKILLS_DATABASE + existing_skills)))
            selected_skills = st.multiselect(
                "Select or Type to Add New Skills", 
                options=all_available_options, 
                default=existing_skills
            )
            skills_in = ", ".join(selected_skills)

        # 6. Generate Tab
        with tabs[5]:
            st.info("Ensure all data is correct before proceeding.")
            submit = st.form_submit_button("🚀 Save Data & Generate Full Preview", use_container_width=True)

    # Logic after form submission
    if submit:
        try:
            profile_payload = {
                "profile_pic": profile_pic_base64, "email": em, "first_name": fn, "last_name": ln, 
                "job_title": jt, "phone": ph, "phone2": ph2, "address": adr, "age": str(age),
                "gender": gen, "summary": summ
            }
            res = supabase.table("profiles").upsert(profile_payload, on_conflict="email").execute()
            p_id = res.data[0]['id']

            supabase.table("education").upsert({"profile_id": p_id, "school": sch, "degree": deg, "field": fld, "grad_year": gy, "cgpa": str(cgpa), "project": proj}, on_conflict="profile_id").execute()
            supabase.table("experience").upsert({"profile_id": p_id, "company_name": cn, "job_title": ex_jt, "duration": f"{dur} Years", "job_description": desc, "achievements": ach}, on_conflict="profile_id").execute()
            
            full_data = profile_payload
            full_data.update({
                "education": [{"school": sch, "degree": deg, "field": fld, "grad_year": gy, "cgpa": cgpa}],
                "experience": [{"company_name": cn, "job_title": ex_jt, "duration": f"{dur} Years", "job_description": desc, "achievements": ach}],
                "certificates": [{"cert_name": c_nm, "organization": c_org, "year": c_yr}],
                "user_references": [{"name": r_nm, "job": r_jb, "phone": r_ph}],
                "skills": [{"name": s.strip()} for s in skills_in.split(",") if s.strip()]
            })

            generator = CVGenerator(design=design, custom_theme=theme_hex, font_family=font_choice)
            st.session_state.current_pdf = generator.create_cv(full_data, section_order)
            st.success("✅ CV Generated Successfully!")
            st.rerun() # Refresh to show PDF below
        except Exception as e:
            st.error(f"Error: {e}")

    # Display PDF below everything if it exists
    if st.session_state.current_pdf:
        st.divider()
        pdf_bytes = bytes(st.session_state.current_pdf)
        base64_pdf = base64.b64encode(pdf_bytes).decode('utf-8')
        pdf_display = f'<iframe src="data:application/pdf;base64,{base64_pdf}" width="100%" height="1000px" style="border-radius:10px; border:none;"></iframe>'
        st.markdown(pdf_display, unsafe_allow_html=True)
        
        st.download_button(
            label="📥 Download Professional CV",
            data=pdf_bytes,
            file_name=f"{fn}_{ln}_CV.pdf",
            mime="application/pdf",
            use_container_width=True
        )