import streamlit as st
from supabase import create_client, Client
import datetime
from pdf_generator import CVGenerator

# --- Supabase Setup ---
SUPABASE_URL = "https://qjtkdkokcvekdkctahdx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqdGtka29rY3Zla2RrY3RhaGR4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDE0MzE4MCwiZXhwIjoyMDg1NzE5MTgwfQ.fNsPMJ5f1cghE4O9OWBqfZsLdNrpCGIo4J4pVjpUiOw"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

st.set_page_config(page_title="CV Maker Pro", layout="wide")

if "user_info" not in st.session_state:
    st.session_state.user_info = {}

st.sidebar.title("🚀 CV Manager")
page = st.sidebar.radio("Go to", ["Dashboard", "Create/Edit CV"])

if page == "Dashboard":
    st.title("📊 My CV Dashboard")
    search_email = st.text_input("የተመዘገቡበትን ኢሜይል ያስገቡ")
    
    if search_email:
        res = supabase.table("profiles").select("*").eq("email", search_email).order("last_updated", desc=True).execute()
        if res.data:
            for item in res.data:
                with st.expander(f"📂 {item.get('cv_name', 'My CV')} - {item.get('job_title', 'No Title')}"):
                    c1, c2 = st.columns(2)
                    if c1.button("📝 Edit", key=f"edit_{item['id']}"):
                        u_id = item['id']
                        # ሁሉንም ዳታ ሰብስቦ መጫን
                        item['education'] = supabase.table("education").select("*").eq("user_id", u_id).execute().data
                        item['experience'] = supabase.table("experience").select("*").eq("user_id", u_id).execute().data
                        item['certificates'] = supabase.table("certificates").select("*").eq("user_id", u_id).execute().data
                        item['skills'] = supabase.table("skills_and_languages").select("*").eq("user_id", u_id).eq("type", "skill").execute().data
                        item['languages'] = supabase.table("skills_and_languages").select("*").eq("user_id", u_id).eq("type", "language").execute().data
                        item['user_references'] = supabase.table("user_references").select("*").eq("user_id", u_id).execute().data
                        
                        st.session_state.user_info = item
                        st.success("ዳታው ተጭኗል! ወደ 'Create/Edit CV' ይሂዱ።")
                    
                    if c2.button("🗑️ Delete", key=f"del_{item['id']}"):
                        supabase.table("profiles").delete().eq("id", item['id']).execute()
                        st.rerun()
        else:
            st.info("ምንም ዳታ አልተገኘም።")

elif page == "Create/Edit CV":
    st.title("📄 CV Builder")
    with st.form("main_cv_form"):
        cv_name_val = st.text_input("CV Name", value=st.session_state.user_info.get("cv_name", "Professional CV"))
        t1, t2, t3, t4, t5 = st.tabs(["👤 Personal", "🎓 Education", "💼 Experience", "📜 Certs & Skills", "🚀 Finish"])
        
        with t1:
            f_name = st.text_input("First Name", value=st.session_state.user_info.get("first_name", ""))
            l_name = st.text_input("Last Name", value=st.session_state.user_info.get("last_name", ""))
            job_title = st.text_input("Job Title", value=st.session_state.user_info.get("job_title", ""))
            email = st.text_input("Email", value=st.session_state.user_info.get("email", ""))
            phone = st.text_input("Phone", value=st.session_state.user_info.get("phone", ""))
            address = st.text_input("Address", value=st.session_state.user_info.get("address", ""))
            summary = st.text_area("Summary", value=st.session_state.user_info.get("summary", ""))
            design = st.selectbox("Design", ["creative", "modern", "minimal", "executive", "classic", "corporate", "bold", "elegant", "professional", "compact"])

        with t2:
            school = st.text_input("School")
            degree = st.text_input("Degree")
            field = st.text_input("Field")
            grad_year = st.text_input("Grad Year")
            cgpa = st.text_input("CGPA")
            project = st.text_area("Project")

        with t3:
            comp = st.text_input("Company")
            pos = st.text_input("Position")
            dur = st.text_input("Duration")
            is_curr = st.checkbox("Currently Working")
            achiev = st.text_area("Achievements")

        with t4:
            cert_n = st.text_input("Cert Name")
            cert_o = st.text_input("Org")
            cert_y = st.text_input("Year")
            skill = st.text_input("Skill")
            lang = st.text_input("Language")

        submit = st.form_submit_button("Save & Generate PDF")

    if submit:
        # Upsert Profile
        profile_payload = {
            "cv_name": cv_name_val, "first_name": f_name, "last_name": l_name, "job_title": job_title,
            "email": email, "phone": phone, "address": address, "summary": summary, "design_type": design,
            "last_updated": datetime.datetime.now().isoformat()
        }
        
        if st.session_state.user_info.get("id"):
            u_id = st.session_state.user_info["id"]
            supabase.table("profiles").update(profile_payload).eq("id", u_id).execute()
        else:
            res = supabase.table("profiles").insert(profile_payload).execute()
            u_id = res.data[0]['id']

        # Sync Related Tables (Delete & Insert)
        for tbl in ["education", "experience", "certificates", "skills_and_languages", "user_references"]:
            supabase.table(tbl).delete().eq("user_id", u_id).execute()

        if school:
            supabase.table("education").insert({"user_id": u_id, "school": school, "degree": degree, "field": field, "grad_year": grad_year, "cgpa": cgpa, "project": project}).execute()
        if comp:
            supabase.table("experience").insert({"user_id": u_id, "company_name": comp, "job_title": pos, "duration": dur, "is_currently_working": is_curr, "achievements": achiev}).execute()
        if cert_n:
            supabase.table("certificates").insert({"user_id": u_id, "cert_name": cert_n, "organization": cert_o, "year": cert_y}).execute()
        if skill:
            supabase.table("skills_and_languages").insert({"user_id": u_id, "name": skill, "type": "skill"}).execute()
        if lang:
            supabase.table("skills_and_languages").insert({"user_id": u_id, "name": lang, "type": "language"}).execute()

        # PDF ዳታ ማዘጋጀት (Key names match CvModel/Flutter structure)
        pdf_data = {
            "firstName": f_name, "lastName": l_name, "jobTitle": job_title, "email": email, "phone": phone, "address": address, "summary": summary,
            "education": [{"school": school, "degree": degree, "field": field, "gradYear": grad_year, "cgpa": cgpa, "project": project}] if school else [],
            "experience": [{"companyName": comp, "jobTitle": pos, "duration": dur, "isCurrentlyWorking": 1 if is_curr else 0, "achievements": achiev}] if comp else [],
            "certificates": [{"certName": cert_n, "organization": cert_o, "year": cert_y}] if cert_n else [],
            "skills": [{"name": skill}] if skill else [],
            "languages": [{"name": lang}] if lang else []
        }
        
        generator = CVGenerator(design=design)
        pdf_bytes = generator.create_cv(pdf_data)
        st.success("Saved!")
        st.download_button("📥 Download PDF", data=pdf_bytes, file_name=f"{cv_name_val}.pdf", mime="application/pdf")