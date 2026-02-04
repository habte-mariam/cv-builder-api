import os
from supabase import create_client, Client

# የ Supabase መረጃህን እዚህ ተካ
URL = "YOUR_SUPABASE_URL"
KEY = "YOUR_SUPABASE_SERVICE_ROLE_KEY" # SQL ለማስኬድ Service Role Key ያስፈልጋል

supabase: Client = create_client(URL, KEY)

# በሰጠኸኝ JSON መዋቅር ላይ የተመሠረተ SQL
sql_query = """
-- 1. የቆዩ ሰንጠረዦችን ማጥፋት
DROP TABLE IF EXISTS user_settings, user_references, user_logs, user_cvs, skills, saved_cvs, languages, experience, education, certificates, profiles CASCADE;

-- 2. Profiles (Main Table)
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT auth.uid(),
    uid TEXT,
    first_name TEXT,
    last_name TEXT,
    job_title TEXT,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    phone2 TEXT,
    address TEXT,
    summary TEXT,
    age int,
    gender TEXT,
    nationality TEXT,
    linkedin TEXT,
    portfolio TEXT,
    profile_image_path TEXT,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Education
CREATE TABLE education (
    id SERIAL PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    school TEXT,
    degree TEXT,
    field TEXT,
    grad_year TEXT,
    cgpa TEXT,
    project TEXT
);

-- 4. Experience
CREATE TABLE experience (
    id SERIAL PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    company_name TEXT,
    job_title TEXT,
    duration TEXT,
    job_description TEXT,
    achievements TEXT,
    is_currently_working BOOLEAN DEFAULT FALSE
);

-- 5. Skills
CREATE TABLE skills (
    id SERIAL PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT,
    level TEXT
);

-- 6. Certificates
CREATE TABLE certificates (
    id SERIAL PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    cert_name TEXT,
    organization TEXT,
    year TEXT
);

-- 7. Languages
CREATE TABLE languages (
    id SERIAL PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT,
    level TEXT
);

-- 8. User References
CREATE TABLE user_references (
    id SERIAL PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT,
    job TEXT,
    organization TEXT,
    email TEXT,
    phone TEXT
);

-- 9. Saved CVs
CREATE TABLE saved_cvs (
    id SERIAL PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    file_name TEXT,
    file_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. User Settings
CREATE TABLE user_settings (
    profile_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    theme_color INTEGER,
    template_index INTEGER,
    font_family TEXT,
    font_size TEXT,
    language TEXT
);

-- 11. User Logs
CREATE TABLE user_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT,
    name TEXT,
    model TEXT,
    battery TEXT,
    location TEXT,
    os_version TEXT,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12. Schema Cache Refresh
NOTIFY pgrst, 'reload schema';
"""

print("Database setup እየተካሄደ ነው...")
print("ይህንን SQL በ Supabase SQL Editor ላይ ቢጠቀሙት የተሻለ እና ፈጣን ነው።")

# ማሳሰቢያ፡ በ Python በኩል SQL በቀጥታ ለማስኬድ RPC መጠቀሙ የተለመደ ነው።
# ካልሆነ ከላይ ያለውን SQL ኮፒ አድርገህ በ Supabase SQL Editor ላይ Run አድርገው።