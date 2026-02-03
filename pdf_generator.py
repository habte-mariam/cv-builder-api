from fpdf import FPDF

# 1. የዲዛይን ስታይሎች መዝገብ
DESIGN_CONFIGS = {
    "creative": {"primary": (255, 87, 34), "secondary": (255, 235, 230), "font": "times"},
    "modern": {"primary": (0, 102, 204), "secondary": (230, 242, 255), "font": "times"},
    "minimal": {"primary": (0, 0, 0), "secondary": (255, 255, 255), "font": "times"},
    "executive": {"primary": (44, 62, 80), "secondary": (236, 240, 241), "font": "times"},
    "classic": {"primary": (50, 50, 50), "secondary": (245, 245, 245), "font": "times"},
    "corporate": {"primary": (26, 35, 126), "secondary": (232, 234, 246), "font": "times"},
    "bold": {"primary": (0, 0, 0), "secondary": (220, 220, 220), "font": "times"},
    "elegant": {"primary": (106, 27, 154), "secondary": (243, 229, 245), "font": "times"},
    "professional": {"primary": (56, 142, 60), "secondary": (232, 245, 233), "font": "times"},
    "compact": {"primary": (121, 85, 72), "secondary": (239, 235, 233), "font": "times"},
}

class CVGenerator(FPDF):
    def __init__(self, design):
        super().__init__()
        self.set_margins(15, 15, 15) 
        self.set_auto_page_break(auto=True, margin=15)
        self.style = DESIGN_CONFIGS.get(design, DESIGN_CONFIGS["professional"])
        self.add_page()

    def add_section_header(self, title):
        self.set_font(self.style["font"], "B", 12)
        self.set_fill_color(*self.style["secondary"])
        self.set_text_color(*self.style["primary"])
        self.cell(180, 8, f"  {title.upper()}", ln=True, fill=True)
        self.ln(2)
        self.set_text_color(0, 0, 0) 

    def create_cv(self, data):
        # --- Header Section ---
        self.set_fill_color(*self.style["primary"])
        self.rect(0, 0, 210, 50, 'F')
        
        self.set_text_color(255, 255, 255)
        self.set_font(self.style["font"], "B", 24)
        self.cell(180, 15, f"{data.get('firstName', '')} {data.get('lastName', '')}", ln=True, align="C")
        
        self.set_font(self.style["font"], "", 14)
        self.cell(180, 7, data.get('jobTitle', '').upper(), ln=True, align="C")
        
        self.set_font(self.style["font"], "", 10)
        contact = f"{data.get('email', '')} | {data.get('phone', '')} | {data.get('address', '')}"
        self.cell(180, 6, contact, ln=True, align="C")
        self.ln(12)
        self.set_text_color(0, 0, 0)

        # --- Summary ---
        if data.get('summary'):
            self.add_section_header("Professional Summary")
            self.set_font(self.style["font"], "", 10)
            self.multi_cell(180, 6, data['summary'])
            self.ln(4)

        # --- Experience ---
        if data.get('experience'):
            self.add_section_header("Experience")
            for exp in data['experience']:
                self.set_font(self.style["font"], "B", 11)
                # isCurrentlyWorking በ CvModelህ መሰረት 1 ከሆነ (Present) ይላል
                curr = "(Present)" if exp.get('isCurrentlyWorking') == 1 else ""
                self.cell(120, 6, f"{exp.get('jobTitle', '')} - {exp.get('companyName', '')}")
                self.set_font(self.style["font"], "", 10)
                self.cell(60, 6, f"{exp.get('duration', '')} {curr}", ln=True, align="R")
                self.multi_cell(180, 5, exp.get('achievements', ''))
                self.ln(2)

        # --- Education ---
        if data.get('education'):
            self.add_section_header("Education")
            for edu in data['education']:
                self.set_font(self.style["font"], "B", 11)
                self.cell(120, 6, f"{edu.get('degree', '')} in {edu.get('field', '')}")
                self.set_font(self.style["font"], "", 10)
                self.cell(60, 6, str(edu.get('gradYear', '')), ln=True, align="R")
                self.cell(180, 5, f"{edu.get('school', '')} | CGPA: {edu.get('cgpa', '')}", ln=True)
                if edu.get('project'):
                    self.set_font(self.style["font"], "I", 9)
                    self.multi_cell(180, 5, f"Project: {edu['project']}")
                self.ln(2)

        # --- Certificates (አዲስ የተጨመረ) ---
        if data.get('certificates'):
            self.add_section_header("Certificates")
            for cert in data['certificates']:
                self.set_font(self.style["font"], "B", 10)
                self.cell(140, 5, cert.get('certName', ''))
                self.set_font(self.style["font"], "", 9)
                self.cell(40, 5, str(cert.get('year', '')), ln=True, align="R")
                self.cell(180, 5, cert.get('organization', ''), ln=True)
                self.ln(1)

        # --- Skills & Languages ---
        if data.get('skills') or data.get('languages'):
            self.add_section_header("Skills & Languages")
            self.set_font(self.style["font"], "", 10)
            if data.get('skills'):
                s_list = ", ".join([s['name'] for s in data['skills'] if s.get('name')])
                self.multi_cell(180, 6, f"Skills: {s_list}")
            if data.get('languages'):
                l_list = ", ".join([f"{l['name']} ({l.get('level', '')})" for l in data['languages'] if l.get('name')])
                self.multi_cell(180, 6, f"Languages: {l_list}")
            self.ln(4)

        # --- References ---
        if data.get('user_references'):
            self.add_section_header("References")
            for ref in data['user_references']:
                self.set_font(self.style["font"], "B", 10)
                self.cell(180, 5, ref.get('name', ''), ln=True)
                self.set_font(self.style["font"], "", 9)
                self.multi_cell(180, 5, f"{ref.get('job', '')} at {ref.get('organization', '')} | {ref.get('phone', '')}")
                self.ln(2)

        return self.output()