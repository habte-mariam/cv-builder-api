# --- 1. JOB CATEGORIES ---
# ማሳሰቢያ፡ በ main.py ላይ Department-ን ስላጠፋነው ይህ ለ AI suggestion ወይም ለሌላ አገልግሎት ሊጠቅም ይችላል።
JOB_CATEGORIES = {
    "Technology & IT": [
        "Software Engineer", "Frontend Developer", "Backend Developer", "Full Stack Developer",
        "Mobile App Developer", "Data Scientist", "Data Analyst", "Database Administrator",
        "System Administrator", "Network Engineer", "Cybersecurity Analyst", "Cloud Architect",
        "DevOps Engineer", "UI/UX Designer", "IT Support Specialist", "Quality Assurance Engineer"
    ],
    "Healthcare & Medical": [
        "General Practitioner", "Specialist Physician", "Nurse", "Pharmacist", "Medical Doctor",
        "Laboratory Technologist", "Radiologist", "Public Health Officer", "Midwife"
    ],
    "Business & Finance": [
        "Accountant", "Auditor", "Finance Manager", "Banker", "Investment Analyst",
        "Project Manager", "Human Resources Manager", "Marketing Manager", "Sales Representative"
    ],
    "Engineering & Architecture": [
        "Civil Engineer", "Mechanical Engineer", "Electrical Engineer", "Chemical Engineer",
        "Architect", "Structural Engineer", "Urban Planner", "Surveyor"
    ],
    "Other Industries": ["Other"]
}

# --- 2. SKILLS DATABASE (Clean & Organized) ---
SKILLS_DATABASE = {
    "Software & IT": [
        "Python", "JavaScript", "Java", "C++", "C#", "PHP", "React.js", "Angular", "Vue.js",
        "Node.js", "Django", "Flask", "PostgreSQL", "MySQL", "MongoDB", "AWS", "Azure",
        "Docker", "Kubernetes", "Git/GitHub", "Cybersecurity", "Data Science", "AI/ML",
        "Flutter", "React Native", "UI/UX Design (Figma)"
    ],
    "Business & Management": [
        "Project Management", "Agile/Scrum", "Business Analysis", "Strategic Planning",
        "Operations Management", "Supply Chain", "Accounting", "Financial Analysis",
        "QuickBooks", "Peachtree", "Human Resources (HR)", "Digital Marketing", "SEO", "CRM"
    ],
    "Healthcare": [
        "Nursing", "Patient Care", "First Aid & CPR", "Clinical Diagnostics", "Medical Coding",
        "Pharmacy Practice", "Pharmacology", "Public Health", "Laboratory Skills", "Radiology"
    ],
    "Engineering & Technical": [
        "Civil Engineering", "Structural Design", "AutoCAD", "ArchiCAD", "Revit", "GIS",
        "Electrical Engineering", "Circuit Design", "PLC Programming", "SolidWorks",
        "Construction Management", "Quality Assurance (QA)"
    ],
    "Office & Communication": [
        "Microsoft Excel (Advanced)", "Microsoft Word", "Microsoft PowerPoint", "Data Entry",
        "English (Fluent)", "Amharic (Native)", "Oromiffa", "Tigrinya", "Translation", "Report Writing"
    ],
    "Universal Soft Skills": [
        "Leadership", "Critical Thinking", "Problem Solving", "Time Management", "Teamwork",
        "Public Speaking", "Emotional Intelligence", "Adaptability", "Conflict Resolution",
        "Customer Service", "Negotiation", "Work Ethic", "Creativity"
    ],
    "Creative & Arts": [
        "Graphic Design", "Adobe Photoshop", "Adobe Illustrator", "Video Editing",
        "Photography", "Copywriting", "Interior Design"
    ]
}

# --- 3. EDUCATION CONSTANTS ---
UNIVERSITIES = [
    "Addis Ababa University", "Bahir Dar University", "Jimma University",
    "Haramaya University", "Hawassa University", "Gondar University",
    "Mekelle University", "Arba Minch University", "Adama Science and Technology University",
    "Addis Ababa Science and Technology University", "Unity University", "Hilcoe", "Other"
]

DEGREE_TYPES = [
    "Grade 1-8", "Grade 9-10", "Grade 11-12", "TVET/Level", "Diploma",
    "Bachelor's Degree", "Master's Degree", "PhD", "Other"
]

FIELDS_OF_STUDY = [
    "Computer Science", "Information Technology", "Software Engineering",
    "Electrical Engineering", "Civil Engineering", "Mechanical Engineering",
    "Accounting and Finance", "Business Management", "Economics",
    "Marketing Management", "Medicine", "Public Health", "Pharmacy",
    "Nursing", "Law", "Psychology", "Architecture", "Statistics", "Other"
]

# --- 4. CERTIFICATES & ORGANIZATIONS ---
DEREJA_CERTIFICATES = [
    "Dereja Academy Job Readiness Program (JRP) Completion",
    "Dereja Academy Soft Skills Training",
    "Dereja Academy Leadership & Employability Skills",
    "Dereja Academy Career Development Certificate"
]

CERTIFICATE_NAMES = DEREJA_CERTIFICATES + [
    "AWS Certified Solutions Architect", "CCNA", "PMP (Project Management)",
    "CISSP", "CompTIA Security+", "Google Data Analytics", "CPA",
    "Full Stack Web Development (ALX)", "IELTS/TOEFL", "Other"
]

ISSUING_ORGANIZATIONS = [
    "Dereja Academy", "EthioCoders (ALX/Holberton)", "Amazon Web Services (AWS)",
    "Cisco", "Project Management Institute (PMI)", "Microsoft", "Google",
    "CompTIA", "Gebeya Training", "Coursera", "Udemy", "Other"
]
# --- 5. LANGUAGE PROFICIENCY LEVELS ---
LANGUAGE_LEVELS = [
    "Beginner", "Intermediate", "Advanced", "Fluent", "Native"
]
# --- 6. EXPERIENCE DURATIONS ---
EXPERIENCE_DURATIONS = [
    "Less than 1 year", "1-2 years", "3-5 years", "6-10 years", "More than 10 years"
]
# --- 7. SKILL LEVELS ---
SKILL_LEVELS = [
    "Beginner", "Intermediate", "Advanced", "Expert"
]
