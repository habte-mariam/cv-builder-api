import streamlit as st
from supabase import create_client, Client
from pdf_generator import CVGenerator
import base64
import google.generativeai as genai

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
design = st.sidebar.selectbox("Design Template", 
    ["creative", "modern", "minimal", "executive", "classic", "corporate", "bold", "elegant", "professional", "compact"])
theme_hex = st.sidebar.color_picker("Theme Color", "#2C3E50")
font_choice = st.sidebar.selectbox("Font Style", ["Arial", "Courier", "Helvetica", "Times"])
section_order = st.sidebar.multiselect(
    "Section Order (Drag to reorder)",
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
    email_q = st.text_input("ኢሜይልዎን ያስገቡ")
    if email_q:
        res = supabase.table("profiles").select("*, education(*), experience(*), skills(*), languages(*), certificates(*), user_references(*)").eq("email", email_q).execute()
        if res.data:
            for user in res.data:
                with st.expander(f"📄 {user['first_name']} {user['last_name']} - {user['job_title']}"):
                    if st.button("ይህንን CV አርትዕ (Edit)", key=user['id']):
                        st.session_state.ui = user
                        st.success("ዳታው ተጭኗል! ወደ 'Create/Edit' ገጽ ይሂዱ።")
        else: st.warning("ምንም መረጃ አልተገኘም።")

# --- Create/Edit CV ---
elif page == "Create/Edit CV":
    ui = st.session_state.ui
    st.title("📝 CV Builder")

    col_form, col_preview = st.columns([0.55, 0.45])

    with col_form:
        tabs = st.tabs(["👤 Profile", "🎓 Education", "💼 Experience", "🎖 Qualifications", "🛠 Skills"])
        
        # 1. Profile Tab
        with tabs[0]:
            # ፎቶ መጫኛ
            uploaded_file = st.file_uploader("የፕሮፋይል ፎቶ ይምረጡ (JPG/PNG)", type=["jpg", "jpeg", "png"])
            
            profile_pic_base64 = ui.get("profile_pic", None)
            
            if uploaded_file is not None:
                # ፎቶውን ወደ base64 መቀየር
                bytes_data = uploaded_file.getvalue()
                profile_pic_base64 = base64.b64encode(bytes_data).decode("utf-8")
                st.image(bytes_data, width=100, caption="የተመረጠው ፎቶ")

            if st.button("🪄 በ AI Summary ጻፍልኝ"):
                job_t = ui.get('job_title', 'Professional')
                with st.spinner("AI በማመንጨት ላይ ነው..."):
                    prompt = f"Write a professional 3-sentence CV summary for a {job_t}."
                    ui['summary'] = get_ai_suggestion(prompt)
                    st.rerun()

        # 3. Experience Tab AI Button
        with tabs[2]:
            if st.button("🪄 የሥራ ዝርዝር በ AI አመንጭ"):
                ex_role = ui.get('experience_job_title', 'Employee')
                ex_comp = ui.get('company_name', 'Company')
                with st.spinner("በመጻፍ ላይ..."):
                    prompt = f"Write 3 professional achievements for a {ex_role} at {ex_comp}."
                    ui['achievements'] = get_ai_suggestion(prompt)
                    st.rerun()

        # ዋናው ዳታ መሙያ ፎርም
        with st.form("cv_universal_form"):
            with tabs[0]: # Profile Fields
                c1, c2 = st.columns(2)
                fn = c1.text_input("First Name", ui.get("first_name", ""))
                ln = c2.text_input("Last Name", ui.get("last_name", ""))
                em = st.text_input("Email", ui.get("email", ""))
                jt = st.text_input("Job Title", ui.get("job_title", ""))
                ph = c1.text_input("Phone", ui.get("phone", ""))
                ph2 = c2.text_input("Secondary Phone", ui.get("phone2", ""))
                adr = st.text_input("Address", ui.get("address", ""))
                age = c1.text_input("Age", ui.get("age", ""))
                gen = c2.selectbox("Gender", ["Male", "Female"], index=0 if ui.get("gender")=="Male" else 1)
                nat = st.text_input("Nationality", ui.get("nationality", ""))
                li = st.text_input("LinkedIn URL", ui.get("linkedin", ""))
                port = st.text_input("Portfolio URL", ui.get("portfolio", ""))
                summ = st.text_area("Professional Summary", ui.get("summary", ""), height=150)
                # State እንዲይዝ
                ui['job_title'] = jt

            with tabs[1]: # Education Fields
                edu_list = ui.get('education', [])
                ed = edu_list[0] if isinstance(edu_list, list) and len(edu_list) > 0 else {}
                sch = st.text_input("School/University", ed.get('school', ""))
                deg = st.text_input("Degree", ed.get('degree', ""))
                fld = st.text_input("Field of Study", ed.get('field', ""))
                gy = st.text_input("Graduation Year", ed.get('grad_year', ""))
                cgpa = st.text_input("CGPA", ed.get('cgpa', ""))
                proj = st.text_area("Final Project", ed.get('project', ""))

            with tabs[2]: # Experience Fields
                exp_list = ui.get('experience', [])
                ex = exp_list[0] if isinstance(exp_list, list) and len(exp_list) > 0 else {}
                cn = st.text_input("Company Name", ex.get('company_name', ""))
                ex_jt = st.text_input("Job Title (Exp)", ex.get('job_title', ""))
                dur = st.text_input("Duration", ex.get('duration', ""))
                curr = st.checkbox("Currently Working Here", value=ex.get('is_currently_working', False))
                desc = st.text_area("Job Description", ex.get('job_description', ""))
                ach = st.text_area("Achievements", ui.get('achievements', ex.get('achievements', "")))
                # State እንዲይዝ
                ui['experience_job_title'] = ex_jt
                ui['company_name'] = cn

            with tabs[3]: # Certificates & References
                col_a, col_b = st.columns(2)
                with col_a:
                    cert_list = ui.get('certificates', [])
                    ce = cert_list[0] if isinstance(cert_list, list) and len(cert_list) > 0 else {}
                    c_nm = st.text_input("Cert Name", ce.get('cert_name', ""))
                    c_org = st.text_input("Issuing Org", ce.get('organization', ""))
                    c_yr = st.text_input("Year Issued", ce.get('year', ""))
                with col_b:
                    ref_list = ui.get('user_references', [])
                    rf = ref_list[0] if isinstance(ref_list, list) and len(ref_list) > 0 else {}
                    r_nm = st.text_input("Ref Name", rf.get('name', ""))
                    r_jb = st.text_input("Ref Job", rf.get('job', ""))
                    r_ph = st.text_input("Ref Phone", rf.get('phone', ""))

            with tabs[4]: # Skills
                sk_val = ", ".join([s['name'] for s in ui.get('skills', [])]) if isinstance(ui.get('skills'), list) else ""
                skills_in = st.text_input("Skills (comma separated)", sk_val)
            
            submit = st.form_submit_button("💾 Save & Generate CV")

        if submit:
            try:
                # 1. Supabase Upsert Logic
                profile_payload = {
                    "profile_pic": profile_pic_base64,
                    "email": em, "first_name": fn, "last_name": ln, "job_title": jt,
                    "phone": ph, "phone2": ph2, "address": adr, "age": age,
                    "gender": gen, "nationality": nat, "linkedin": li, "portfolio": port, "summary": summ
                }
                res = supabase.table("profiles").upsert(profile_payload, on_conflict="email").execute()
                p_id = res.data[0]['id']

                # 2. Update Table Data
                if sch:
                    supabase.table("education").upsert({"profile_id": p_id, "school": sch, "degree": deg, "field": fld, "grad_year": gy, "cgpa": cgpa, "project": proj}, on_conflict="profile_id").execute()
                if cn:
                    supabase.table("experience").upsert({"profile_id": p_id, "company_name": cn, "job_title": ex_jt, "duration": dur, "is_currently_working": curr, "job_description": desc, "achievements": ach}, on_conflict="profile_id").execute()
                
                # 3. PDF Data Prep
                full_data = profile_payload
                full_data.update({
                    "profile_pic": profile_pic_base64,
                    "education": [{"school": sch, "degree": deg, "field": fld, "grad_year": gy, "cgpa": cgpa, "project": proj}],
                    "experience": [{"company_name": cn, "job_title": ex_jt, "duration": dur, "job_description": desc, "achievements": ach}],
                    "certificates": [{"cert_name": c_nm, "organization": c_org, "year": c_yr}],
                    "user_references": [{"name": r_nm, "job": r_jb, "phone": r_ph}],
                    "skills": [{"name": s.strip()} for s in skills_in.split(",") if s.strip()]
                })

                # 4. Generate & Save to State
                generator = CVGenerator(design=design, custom_theme=theme_hex, font_family=font_choice)
                st.session_state.current_pdf = generator.create_cv(full_data, section_order)
                st.success("✅ CV ተዘጋጅቷል!")
            except Exception as e:
                st.error(f"ስህተት ተከስቷል: {e}")

    # --- Right Column: Live Iframe Preview ---
    with col_preview:
        st.subheader("👀 Live Preview")
        if st.session_state.current_pdf:
            pdf_to_download = bytes(st.session_state.current_pdf)
            base64_pdf = base64.b64encode(pdf_to_download).decode('utf-8')
            pdf_display = f'<iframe src="data:application/pdf;base64,{base64_pdf}" width="100%" height="850px" style="border: 2px solid #eee;"></iframe>'
            st.markdown(pdf_display, unsafe_allow_html=True)
            
            st.download_button(
                label="📥 Download PDF",
                data=pdf_to_download,
                file_name=f"{fn}_{ln}_CV.pdf",
                mime="application/pdf",
                use_container_width=True
            )
        else:
            st.info("መረጃውን ሞልተው 'Save & Generate' ሲሉ ውጤቱ እዚህ ይታያል።")