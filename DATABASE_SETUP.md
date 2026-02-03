# 🗄️ Database Setup Instructions

⚠️ **IMPORTANT SECURITY NOTE:** SQL files are NOT included in this repository for security reasons. Follow the instructions below to set up your database.

---

## 📋 Quick Setup

### Step 1: Create Supabase Project
1. Go to [https://supabase.com](https://supabase.com)
2. Create a new project
3. Save your database password

### Step 2: Set Up Database Tables

Go to **SQL Editor** in your Supabase dashboard and run the following SQL:

#### Create Tables:
```sql
-- Lessons table
CREATE TABLE lessons (
  id SERIAL PRIMARY KEY,
  lesson_name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Vocabulary table
CREATE TABLE vocabulary (
  id SERIAL PRIMARY KEY,
  lesson_id INTEGER REFERENCES lessons(id) ON DELETE CASCADE,
  displayWord TEXT NOT NULL,
  hiragana TEXT NOT NULL,
  romaji TEXT NOT NULL,
  english TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- User profiles table
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  display_name TEXT,
  lesson_id INTEGER NOT NULL REFERENCES lessons(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- User progress table
CREATE TABLE user_progress (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  vocabulary_id INTEGER REFERENCES vocabulary(id) ON DELETE CASCADE,
  status TEXT CHECK (status IN ('known', 'learning', 'new')) DEFAULT 'new',
  last_reviewed TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, vocabulary_id)
);

-- User sessions table
CREATE TABLE user_sessions (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  lesson_id INTEGER REFERENCES lessons(id) ON DELETE CASCADE,
  session_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  cards_studied INTEGER DEFAULT 0,
  cards_known INTEGER DEFAULT 0,
  cards_learning INTEGER DEFAULT 0,
  duration_minutes INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

#### Create Indexes:
```sql
CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_vocabulary_id ON user_progress(vocabulary_id);
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_profiles_username ON user_profiles(username);
CREATE INDEX idx_user_profiles_lesson_id ON user_profiles(lesson_id);
```

#### Enable Row Level Security (RLS):
```sql
-- Enable RLS on all tables
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE vocabulary ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

-- Lessons: Public read access
CREATE POLICY "Public read access to lessons"
  ON lessons FOR SELECT
  TO authenticated
  USING (true);

-- Vocabulary: Public read access
CREATE POLICY "Public read access to vocabulary"
  ON vocabulary FOR SELECT
  TO authenticated
  USING (true);

-- User Profiles: Read all (for login), modify own
CREATE POLICY "Public can view profiles for login"
  ON user_profiles FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- User Progress: Own data only
CREATE POLICY "Users can view their own progress"
  ON user_progress FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own progress"
  ON user_progress FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress"
  ON user_progress FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own progress"
  ON user_progress FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- User Sessions: Own data only
CREATE POLICY "Users can view their own sessions"
  ON user_sessions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sessions"
  ON user_sessions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);
```

#### Create Trigger Function:
```sql
-- Auto-create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, username, email, display_name, lesson_id)
  VALUES (
    NEW.id,
    LOWER(COALESCE(NEW.raw_user_meta_data->>'username', SPLIT_PART(NEW.email, '@', 1))),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', SPLIT_PART(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'lesson_id')::INTEGER, 1)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_user_profile_updated
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
```

### Step 3: Insert Sample Data

You can insert sample lessons and vocabulary through the Supabase dashboard or contact the project maintainer for sample data.

---

## 🔒 Security Notes

- **SQL files are NOT in this repo** - This prevents accidental exposure of database structure
- **RLS is enabled** - Users can only see their own data
- **API keys** - Only the anon/public key is used in frontend (this is safe)
- **Never commit** - Database credentials, service role keys, or admin keys

---

## 🔧 Configuration

### Get Your Supabase Credentials:

1. Go to **Settings** → **API**
2. Copy these values:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon/public key**: `eyJhbGc...`

3. Update in your code:
   - `login.html`
   - `greeting.html`

**Note:** The anon key is safe to expose in frontend code - it's designed for this purpose. RLS policies protect your data.

---

## 📊 Database Schema

### Tables:
- `lessons` - Lesson information (shared)
- `vocabulary` - Word data (shared)
- `user_profiles` - User info (per user)
- `user_progress` - Learning progress (per user, RLS protected)
- `user_sessions` - Study sessions (per user, RLS protected)

### Relationships:
```
lessons (1) ─── (many) vocabulary
   │
   └─── (many) user_sessions

auth.users (1) ─── (1) user_profiles
   │
   ├─── (many) user_progress
   └─── (many) user_sessions

vocabulary (1) ─── (many) user_progress
```

---

## 🆘 Troubleshooting

### Table doesn't exist
- Make sure you ran all CREATE TABLE statements
- Check for errors in SQL Editor

### RLS blocking access
- Verify policies are created
- Make sure user is authenticated
- Check policy conditions match your use case

### Trigger not working
- Verify function is created
- Check trigger is attached to auth.users table
- Look for errors in Supabase logs

---

## 📞 Need Help?

For questions about database setup:
1. Check Supabase documentation: https://supabase.com/docs
2. Open an issue in this repository
3. Review the authentication setup guide

---

**⚠️ NEVER commit `.sql` files to public repositories!**

This document provides all the SQL you need without exposing your database structure in version control.
