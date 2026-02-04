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
        
        # ፎቶው ካለ ወደ ፒዲኤፍ መጨመር
        profile_pic = data.get("profile_pic")
        if profile_pic:
            try:
                img_data = base64.b64decode(profile_pic)
                with tempfile.NamedTemporaryFile(delete=False, suffix=".png") as tmp:
                    tmp.write(img_data)
                    tmp_path = tmp.name
                
                # ፎቶውን ከላይ ቀኝ በኩል ማስቀመጥ
                self.image(tmp_path, x=170, y=10, w=30)
                # ፋይሉን በኋላ ማጥፋት (Cleanup)
                os.unlink(tmp_path)
            except Exception as e:
                print(f"Photo Error: {e}")

        # 1. Header Logic based on Design
        if self.design in ["creative", "bold", "modern"]:
            self._draw_colored_header(data)
        else:
            self._draw_classic_header(data)

        # 2. Dynamic Section Rendering
        for section in section_order:
            if section == "Summary" and data.get('summary'):
                self._add_summary(data['summary'])
            elif section == "Experience" and data.get('experience'):
                self._add_experience(data['experience'])
            elif section == "Education" and data.get('education'):
                self._add_education(data['education'])
            elif section == "Skills" and data.get('skills'):
                self._add_skills(data['skills'])
            elif section == "Certificates" and data.get('certificates'):
                self._add_certificates(data['certificates'])
            elif section == "References" and data.get('user_references'):
                self._add_references(data['user_references'])

        # Output as bytes for Streamlit
        return bytes(self.output(dest='S'))

    # --- Header Styles ---
    def _draw_colored_header(self, data):
        self.set_fill_color(*self.primary_color)
        self.rect(0, 0, 210, 55, 'F')
        self.set_y(15)
        self.set_text_color(255, 255, 255)
        self.set_font(self.font_name, "B", 24)
        full_name = f"{data.get('first_name', '')} {data.get('last_name', '')}".upper()
        self.cell(0, 10, full_name, ln=True, align='C')
        
        self.set_font(self.font_name, "", 14)
        self.cell(0, 8, data.get('job_title', ''), ln=True, align='C')
        
        # Contact bar in header
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
        self.line(10, self.get_y(), 40, self.get_y()) # Short underline
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
            if ex.get('achievements'):
                self.set_text_color(80, 80, 80)
                self.multi_cell(0, 5, f"Key Achievements: {ex.get('achievements')}")
                self.set_text_color(0, 0, 0)
            self.ln(2)

    def _add_education(self, edu_list):
        self._section_title("Education")
        for ed in edu_list:
            if not ed.get('school'): continue
            self.set_font(self.font_name, "B", 11)
            self.cell(150, 6, f"{ed.get('degree')} in {ed.get('field')}")
            self.cell(0, 6, ed.get('grad_year', ''), align='R', ln=True)
            self.set_font(self.font_name, "", 10)
            self.cell(0, 5, f"{ed.get('school')} | CGPA: {ed.get('cgpa', 'N/A')}", ln=True)
            if ed.get('project'):
                self.set_font(self.font_name, "I", 9)
                self.multi_cell(0, 4, f"Project: {ed.get('project')}")
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
            self.cell(0, 5, str(c.get('year', '')), align='R', ln=True)
            self.set_font(self.font_name, "", 9)
            self.cell(0, 5, c.get('organization', ''), ln=True)

    def _add_references(self, ref_list):
        self._section_title("References")
        for r in ref_list:
            if not r.get('name'): continue
            self.set_font(self.font_name, "B", 10)
            self.cell(0, 5, r.get('name'), ln=True)
            self.set_font(self.font_name, "", 9)
            self.cell(0, 4, f"{r.get('job', '')}", ln=True)
            self.cell(0, 4, f"Phone: {r.get('phone', '')}", ln=True)
            self.ln(2)
        return bytes(self.output(dest='S'))