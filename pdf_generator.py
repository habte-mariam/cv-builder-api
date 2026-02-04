import base64
from fpdf import FPDF
import tempfile
import os

class CVGenerator(FPDF):
    def __init__(self, design="modern", custom_theme="#2C3E50", font_family="Arial"):
        super().__init__()
        self.design = design
        self.primary_color = self._hex_to_rgb(custom_theme)
        # Font checks
        available_fonts = ["Arial", "Courier", "Helvetica", "Times"]
        self.font_name = font_family if font_family in available_fonts else "Arial"
        self.set_auto_page_break(auto=True, margin=15)

    def _hex_to_rgb(self, hex_str):
        h = hex_str.lstrip('#')
        return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

    def create_cv(self, data, section_order):
        self.add_page()
        
        # 1. መጀመሪያ Header (ቀለሙን) መሳል
        if self.design in ["creative", "bold", "modern"]:
            self._draw_colored_header(data)
        else:
            self._draw_classic_header(data)

        # 2. በመቀጠል ፎቶውን ክብ (Circular Style) አድርጎ መሳል
        profile_pic = data.get("profile_pic")
        if profile_pic:
            try:
                img_data = base64.b64decode(profile_pic)
                with tempfile.NamedTemporaryFile(delete=False, suffix=".png") as tmp:
                    tmp.write(img_data)
                    tmp_path = tmp.name
                
                # ፎቶውን ማስቀመጥ (ከቀለሙ በላይ እንዲሆን)
                # x=172 (በስተቀኝ), y=10 (ከላይ), w=28 (ስፋት)
                self.image(tmp_path, x=172, y=10, w=28, h=28) 
                
                # በፎቶው ዙሪያ ክብ መስመር በማስመር ክብ እንዲመስል ማድረግ
                self.set_draw_color(255, 255, 255) # ነጭ መስመር
                self.set_line_width(1)
                self.ellipse(172, 10, 28, 28)
                
                os.unlink(tmp_path)
            except Exception as e:
                print(f"Photo Error: {e}")

        # 3. Dynamic Sections (ባዶ የሆኑትን በማስወገድ)
        for section in section_order:
            if section == "Summary" and data.get('summary'):
                self._add_summary(data['summary'])
            
            elif section == "Experience" and data.get('experience'):
                exp = data['experience']
                if isinstance(exp, list) and len(exp) > 0 and exp[0].get('company_name'):
                    self._add_experience(exp)
            
            elif section == "Education" and data.get('education'):
                edu = data['education']
                if isinstance(edu, list) and len(edu) > 0 and edu[0].get('school'):
                    self._add_education(edu)
            
            elif section == "Skills" and data.get('skills'):
                skill_names = [s.get('name') for s in data['skills'] if s.get('name')]
                if skill_names:
                    self._add_skills(data['skills'])
            
            elif section == "Certificates" and data.get('certificates'):
                cert = data['certificates']
                if isinstance(cert, list) and len(cert) > 0 and cert[0].get('cert_name'):
                    self._add_certificates(cert)
            
            elif section == "References" and data.get('user_references'):
                ref = data['user_references']
                if isinstance(ref, list) and len(ref) > 0 and ref[0].get('name'):
                    self._add_references(ref)

        return bytes(self.output(dest='S'))

    # --- Header Styles ---
    def _draw_colored_header(self, data):
        self.set_fill_color(*self.primary_color)
        self.rect(0, 0, 210, 50, 'F')
        self.set_y(12)
        self.set_text_color(255, 255, 255)
        self.set_font(self.font_name, "B", 24)
        full_name = f"{data.get('first_name', '')} {data.get('last_name', '')}".upper()
        self.cell(0, 10, full_name, ln=True, align='C')
        
        self.set_font(self.font_name, "", 14)
        self.cell(0, 8, data.get('job_title', ''), ln=True, align='C')
        
        self.set_font(self.font_name, "", 9)
        contact_info = f"{data.get('email', '')}  |  {data.get('phone', '')}  |  {data.get('address', '')}"
        self.cell(0, 10, contact_info, ln=True, align='C')
        self.ln(15)
        self.set_text_color(0, 0, 0)

    def _draw_classic_header(self, data):
        self.set_y(15)
        self.set_text_color(*self.primary_color)
        self.set_font(self.font_name, "B", 22)
        full_name = f"{data.get('first_name', '')} {data.get('last_name', '')}"
        self.cell(0, 10, full_name, ln=True, align='L')
        
        self.set_text_color(100, 100, 100)
        self.set_font(self.font_name, "B", 13)
        self.cell(0, 8, data.get('job_title', '').upper(), ln=True, align='L')
        
        self.set_draw_color(*self.primary_color)
        self.line(10, self.get_y()+2, 200, self.get_y()+2)
        self.ln(10)
        self.set_text_color(0, 0, 0)

    # --- Sections ---
    def _section_title(self, title):
        self.ln(4)
        self.set_font(self.font_name, "B", 12)
        self.set_text_color(*self.primary_color)
        self.cell(0, 8, title.upper(), ln=True)
        self.set_draw_color(*self.primary_color)
        self.line(10, self.get_y(), 40, self.get_y())
        self.ln(2)
        self.set_text_color(0, 0, 0)

    def _add_summary(self, text):
        self._section_title("Summary")
        self.set_font(self.font_name, "", 10)
        self.multi_cell(0, 5, text)

    def _add_experience(self, exp_list):
        self._section_title("Work Experience")
        for ex in exp_list:
            if not ex.get('company_name'): continue
            self.set_font(self.font_name, "B", 11)
            self.cell(140, 6, f"{ex.get('job_title')} at {ex.get('company_name')}")
            self.set_font(self.font_name, "I", 10)
            self.cell(0, 6, ex.get('duration', ''), align='R', ln=True)
            
            self.set_font(self.font_name, "", 10)
            if ex.get('job_description'):
                self.multi_cell(0, 5, ex.get('job_description'))
            self.ln(2)

    def _add_education(self, edu_list):
        self._section_title("Education")
        for ed in edu_list:
            if not ed.get('school'): continue
            self.set_font(self.font_name, "B", 11)
            self.cell(150, 6, f"{ed.get('degree')} in {ed.get('field')}")
            
            # ዓመቱን ወደ string መቀየር
            grad_year = str(ed.get('grad_year', ''))
            self.cell(0, 6, grad_year, align='R', ln=True)
            
            self.set_font(self.font_name, "", 10)
            # CGPA ቁጥር ሊሆን ስለሚችል እሱንም str() ውስጥ ክተተው
            cgpa_val = str(ed.get('cgpa', 'N/A'))
            self.cell(0, 5, f"{ed.get('school')} | CGPA: {cgpa_val}", ln=True)
            self.ln(2)

    def _add_skills(self, skill_list):
        self._section_title("Skills & Proficiencies")
        self.set_font(self.font_name, "", 10)
        skill_names = [s.get('name') for s in skill_list if s.get('name')]
        skill_line = ", ".join(skill_names)
        self.multi_cell(0, 5, skill_line)

    def _add_certificates(self, cert_list):
        self._section_title("Certificates")
        for c in cert_list:
            if not c.get('cert_name'): continue
            self.set_font(self.font_name, "B", 10)
            self.cell(150, 5, c.get('cert_name'))
            
            # ስህተቱ እዚህ ጋር ነው - ዓመተ ምህረቱን (year) ወደ string መቀየር አለብህ
            year_val = str(c.get('year', '')) 
            self.cell(0, 5, year_val, align='R', ln=True)
            self.ln(1)

    def _add_references(self, ref_list):
        self._section_title("References")
        for r in ref_list:
            if not r.get('name'): continue
            self.set_font(self.font_name, "B", 10)
            self.cell(0, 5, r.get('name'), ln=True)
            self.set_font(self.font_name, "", 9)
            self.cell(0, 4, f"Phone: {r.get('phone', '')}", ln=True)
            self.ln(2)
        return bytes(self.output(dest='S'))