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

SKILLS_DATABASE = {
    "Software & IT": [
        "Python", "JavaScript", "Java", "C++", "C#", "PHP", "Ruby", "Swift", "Kotlin", "Go",
        "React.js", "Angular", "Vue.js", "Next.js", "HTML5", "CSS3", "Tailwind CSS", "Bootstrap",
        "Node.js", "Django", "Flask", "Laravel", "Spring Boot", "ASP.NET", "FastAPI",
        "PostgreSQL", "MySQL", "MongoDB", "Redis", "Oracle", "Firebase", "Supabase",
        "AWS", "Azure", "Google Cloud", "Docker", "Kubernetes", "CI/CD", "Terraform",
        "Git", "GitHub", "Linux/Unix", "Cybersecurity", "Ethical Hacking", "Network Admin",
        "Data Science", "Machine Learning", "AI", "Pandas", "NumPy", "TensorFlow", "PyTorch",
        "Mobile App Development", "Flutter", "React Native", "UI/UX Design", "Figma", "Adobe XD"
    ],
    "Business & Management": [
        "Project Management", "Agile/Scrum", "Business Analysis", "Strategic Planning", "Leadership",
        "Operations Management", "Supply Chain Management", "Logistics", "Risk Management",
        "Accounting", "Financial Analysis", "Taxation", "Auditing", "QuickBooks", "Peachtree",
        "Human Resources (HR)", "Recruitment", "Employee Relations", "Payroll Management",
        "Sales & Marketing", "Digital Marketing", "SEO", "Social Media Management", "Content Strategy",
        "Public Relations", "Customer Relationship Management (CRM)", "Salesforce", "Market Research",
        "Business Development", "Contract Negotiation", "Entrepreneurship", "Public Speaking"
    ],
    "Healthcare": [
        "Nursing", "Patient Care", "First Aid & CPR", "Clinical Diagnostics", "Medical Coding",
        "Health Information Management", "Pharmacy Practice", "Pharmacology", "Public Health",
        "Emergency Medicine", "Surgery Assistance", "Laboratory Skills", "Radiology",
        "Physical Therapy", "Mental Health Counseling", "Anatomy", "Physiology", "Medical Ethics",
        "Hospital Administration", "Infection Control", "Nutrition & Dietetics"
    ],
    "Engineering & Technical": [
        "Civil Engineering", "Structural Design", "AutoCAD", "ArchiCAD", "Revit", "GIS",
        "Electrical Engineering", "Circuit Design", "Power Systems", "PLC Programming",
        "Mechanical Engineering", "SolidWorks", "Thermodynamics", "Manufacturing Processes",
        "Chemical Engineering", "Process Control", "Quality Assurance (QA)", "ISO Standards",
        "Technical Writing", "Surveying", "Construction Management", "Renewable Energy Systems"
    ],
    "Language & Communication": [
        "English (Fluent)", "Amharic (Native)", "Oromiffa", "Tigrinya", "French", "Arabic", "Chinese",
        "Technical Communication", "Interpersonal Skills", "Conflict Resolution", "Translation",
        "Report Writing", "Presentation Skills", "Teamwork", "Customer Service", "Emotional Intelligence"
    ],
    "Office & Administration": [
        "Microsoft Word", "Microsoft Excel (Advanced)", "Microsoft PowerPoint", "Data Entry",
        "Office Management", "Scheduling & Calendar Management", "Record Keeping",
        "Transcription", "Virtual Assistance", "Email Communication", "Typing Speed (60+ WPM)"
    ],
    
    "General Soft Skills": [
        # Communication
        "Verbal Communication", "Written Communication", "Active Listening", "Public Speaking", 
        "Presentation Skills", "Interpersonal Skills", "Negotiation", "Persuasion", "Storytelling",
        "Constructive Feedback", "Technical Writing", "Grant Writing", "Editing", "Proofreading",
        "Cross-Cultural Communication", "Diplomacy", "Clarifying", "Non-Verbal Communication",
        # Leadership & Management
        "Leadership", "Team Management", "Conflict Resolution", "Decision Making", "Strategic Thinking",
        "Mentoring", "Coaching", "Delegation", "Crisis Management", "Change Management", "Goal Setting",
        "Performance Management", "Project Planning", "Meeting Facilitation", "Talent Development",
        "Inspirational Leadership", "Remote Team Management", "Inclusivity", "Empowerment",
        # Thinking & Problem Solving
        "Critical Thinking", "Problem Solving", "Analytical Reasoning", "Creativity", "Innovation",
        "Logical Reasoning", "Design Thinking", "Strategic Planning", "Cognitive Flexibility",
        "Information Processing", "Conceptual Thinking", "Intuition", "Root Cause Analysis",
        # Emotional Intelligence (EQ)
        "Emotional Intelligence", "Self-Awareness", "Self-Regulation", "Empathy", "Social Skills",
        "Relationship Management", "Patience", "Resilience", "Compassion", "Cultural Sensitivity",
        "Stress Management", "Emotional Control", "Adaptability", "Trust Building",
        # Professionalism & Work Ethic
        "Time Management", "Prioritization", "Organization", "Work Ethic", "Integrity", "Reliability",
        "Dependability", "Attention to Detail", "Multi-tasking", "Punctuality", "Discipline",
        "Accountability", "Professionalism", "Ethical Conduct", "Discretion", "Growth Mindset",
        "Self-Motivation", "Lifelong Learning", "Resourcefulness", "Professional Networking",
        # Collaboration & Teamwork
        "Teamwork", "Collaboration", "Virtual Collaboration", "Peer Support", "Knowledge Sharing",
        "Cooperation", "Team Building", "Group Dynamics", "Consensus Building", "Remote Work Proficiency",
        # Customer & Client Relations
        "Customer Service", "Customer Experience (CX)", "Client Management", "Conflict De-escalation",
        "Patient Advocacy", "Salesmanship", "Service Orientation", "Community Outreach", "Public Relations",
        "Building Rapport", "Account Management", "Satisfaction Surveys",
        # Personal Productivity & Others
        "Planning", "Focus", "Efficiency", "Continuous Improvement", "Curiosity", "Independent Work",
        "Stress Tolerance", "Goal Orientation", "Decision Quality", "Active Learning", "Critical Observation",
        "Digital Literacy", "Information Literacy", "Online Research", "Data Interpretation", "Tech-Savviness"
    ],
    
    "Creative & Arts": [
        "Graphic Design", "Adobe Photoshop", "Adobe Illustrator", "InDesign", "Video Editing",
        "Adobe Premiere Pro", "After Effects", "Photography", "Animation", "Copywriting",
        "Creative Writing", "Interior Design", "Fashion Design", "Music Production"
    ]
    
}

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