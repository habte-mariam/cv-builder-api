# constants.py

JOB_CATEGORIES = {
    "Technology & IT": [
        "Software Engineer", "Frontend Developer", "Backend Developer", "Full Stack Developer",
        "Mobile App Developer", "Data Scientist", "Data Analyst", "Database Administrator",
        "System Administrator", "Network Engineer", "Cybersecurity Analyst", "Cloud Architect",
        "DevOps Engineer", "UI/UX Designer", "IT Support Specialist", "Quality Assurance Engineer",
        "Machine Learning Engineer", "Blockchain Developer", "Game Developer", "Embedded Systems Engineer"
    ],
    "Healthcare & Medical": [
        "General Practitioner", "Specialist Physician", "Nurse", "Pharmacist", "Medical Doctor",
        "Laboratory Technologist", "Radiologist", "Dentist", "Physiotherapist", "Public Health Officer",
        "Midwife", "Surgeon", "Anesthesiologist", "Nutritionist", "Psychologist", "Health Administrator"
    ],
    "Business, Finance & Management": [
        "Accountant", "Auditor", "Finance Manager", "Banker", "Investment Analyst",
        "Project Manager", "Human Resources Manager", "Marketing Manager", "Sales Representative",
        "Business Analyst", "Operations Manager", "Strategic Planner", "Logistics Coordinator",
        "Supply Chain Manager", "Entrepreneur", "Office Administrator", "Risk Manager"
    ],
    "Engineering & Architecture": [
        "Civil Engineer", "Mechanical Engineer", "Electrical Engineer", "Chemical Engineer",
        "Architect", "Structural Engineer", "Geotechnical Engineer", "Hydraulic Engineer",
        "Sanitary Engineer", "Urban Planner", "Interior Designer", "Surveyor"
    ],
    "Education & Social Science": [
        "Lecturer", "High School Teacher", "Primary School Teacher", "Social Worker",
        "Researcher", "Librarian", "Counselor", "Curriculum Developer", "Sociologist",
        "Linguist", "Economist", "Political Scientist", "Historian"
    ],
    "Legal & Communication": [
        "Lawyer", "Legal Consultant", "Judge", "Prosecutor", "Journalist", "Public Relations Officer",
        "Content Creator", "Editor", "Translator", "Interpreter", "Media Producer"
    ],
    "Other Industries": ["Other"]
}

SKILLS_DATABASE = [
    "Python", "Java", "JavaScript", "C++", "SQL", "React", "Node.js", "Flutter", "Dart",
    "Project Management", "Data Analysis", "Machine Learning", "Graphic Design", "Leadership",
    "Customer Service", "Critical Thinking", "Teamwork", "Public Speaking", "Microsoft Office",
    "Accounting Software", "AutoCAD", "GIS", "Stata", "SPSS", "Digital Marketing", "SEO"
]

# constants.py ውስጥ ጨምር

UNIVERSITIES = [
    "Addis Ababa University", "Bahir Dar University", "Jimma University", 
    "Haramaya University", "Hawassa University", "Gondar University", 
    "Mekelle University", "Arba Minch University", "Adama Science and Technology University", 
    "Addis Ababa Science and Technology University", "Unity University", "Hilcoe", "Other"
]

DEGREE_TYPES = [
    "Grade 1-8", 
    "Grade 9-10", 
    "Grade 11-12", 
    "TVET/Level", 
    "Diploma", 
    "Bachelor's Degree", 
    "Master's Degree", 
    "PhD", 
    "Other"
]


FIELDS_OF_STUDY = [
    "Computer Science", "Information Technology", "Software Engineering", 
    "Electrical Engineering", "Civil Engineering", "Mechanical Engineering", 
    "Accounting and Finance", "Business Management", "Economics", 
    "Marketing Management", "Medicine", "Public Health", "Pharmacy", 
    "Nursing", "Law", "Psychology", "Sociology", "Political Science", 
    "Architecture", "Statistics", "Mathematics", "Physics", "Chemistry", 
    "Biology", "Other"
]

# constants.py

# የደረጃ አካዳሚ ዝርዝር (ለብቻው ለ Logic እንዲመች)
DEREJA_CERTIFICATES = [
    "Dereja Academy Job Readiness Program (JRP) Completion",
    "Dereja Academy Soft Skills Training",
    "Dereja Academy Leadership & Employability Skills",
    "Dereja Academy Career Development Certificate",
    "Dereja Academy Professional Communication Skills",
    "Dereja Academy Critical Thinking & Problem Solving",
    "Dereja Academy Digital Literacy for Workplace"
]

# ሁሉንም ያጣመረ የሰርተፍኬት ስሞች ዝርዝር
CERTIFICATE_NAMES = DEREJA_CERTIFICATES + [
    "AWS Certified Solutions Architect", 
    "Cisco Certified Network Associate (CCNA)",
    "Project Management Professional (PMP)", 
    "Certified Information Systems Security Professional (CISSP)",
    "CompTIA A+", 
    "CompTIA Security+", 
    "Microsoft Certified: Azure Fundamentals",
    "Google Data Analytics Professional Certificate", 
    "CPA (Certified Public Accountant)",
    "Full Stack Web Development (EthioCoders/ALX)", 
    "IELTS Academic/General", 
    "TOEFL", 
    "Other"
]

# ሰጪ ተቋማት (የሀገር ውስጥና ዓለም አቀፍ ድርጅቶች ጥምረት)
ISSUING_ORGANIZATIONS = [
    "Dereja Academy", 
    "EthioCoders (ALX/Holberton)", 
    "Amazon Web Services (AWS)", 
    "Cisco", 
    "Project Management Institute (PMI)",
    "Microsoft", 
    "Google", 
    "CompTIA", 
    "Gebeya Training",
    "Coursera", 
    "Udemy", 
    "LinkedIn Learning",
    "Oracle", 
    "IBM", 
    "Other"
]