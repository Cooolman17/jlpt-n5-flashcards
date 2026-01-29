-- ========================================
-- JLPT N5 Flashcards - Complete Database Setup with Authentication
-- ========================================
-- Run this in your Supabase SQL Editor

-- ========================================
-- Step 1: Create Tables
-- ========================================

-- Lessons table (shared across all users)
CREATE TABLE IF NOT EXISTS lessons (
  id SERIAL PRIMARY KEY,
  lesson_number INTEGER NOT NULL,
  lesson_name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Vocabulary table (shared across all users)
CREATE TABLE IF NOT EXISTS vocabulary (
  id SERIAL PRIMARY KEY,
  lesson_id INTEGER REFERENCES lessons(id) ON DELETE CASCADE,
  jp TEXT NOT NULL,
  hiragana TEXT NOT NULL,
  romaji TEXT NOT NULL,
  en TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- User profiles table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- User progress table (tracks individual user progress)
CREATE TABLE IF NOT EXISTS user_progress (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  vocabulary_id INTEGER REFERENCES vocabulary(id) ON DELETE CASCADE,
  status TEXT CHECK (status IN ('known', 'learning', 'new')) DEFAULT 'new',
  last_reviewed TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, vocabulary_id)
);

-- User sessions table (track user study sessions)
CREATE TABLE IF NOT EXISTS user_sessions (
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

-- ========================================
-- Step 2: Create Indexes for Performance
-- ========================================

CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_vocabulary_id ON user_progress(vocabulary_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_username ON user_profiles(username);

-- ========================================
-- Step 3: Enable Row Level Security (RLS)
-- ========================================

-- Enable RLS on all tables
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE vocabulary ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

-- ========================================
-- Step 4: Create RLS Policies
-- ========================================

-- Lessons: Public read access (all users can see all lessons)
DROP POLICY IF EXISTS "Public read access to lessons" ON lessons;
CREATE POLICY "Public read access to lessons"
  ON lessons FOR SELECT
  TO authenticated
  USING (true);

-- Vocabulary: Public read access (all users can see all vocabulary)
DROP POLICY IF EXISTS "Public read access to vocabulary" ON vocabulary;
CREATE POLICY "Public read access to vocabulary"
  ON vocabulary FOR SELECT
  TO authenticated
  USING (true);

-- User Profiles: Users can read all profiles but only update their own
DROP POLICY IF EXISTS "Users can view all profiles" ON user_profiles;
CREATE POLICY "Users can view all profiles"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Users can insert their own profile" ON user_profiles;
CREATE POLICY "Users can insert their own profile"
  ON user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;
CREATE POLICY "Users can update their own profile"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- User Progress: Users can only see and modify their own progress
DROP POLICY IF EXISTS "Users can view their own progress" ON user_progress;
CREATE POLICY "Users can view their own progress"
  ON user_progress FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own progress" ON user_progress;
CREATE POLICY "Users can insert their own progress"
  ON user_progress FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own progress" ON user_progress;
CREATE POLICY "Users can update their own progress"
  ON user_progress FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own progress" ON user_progress;
CREATE POLICY "Users can delete their own progress"
  ON user_progress FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- User Sessions: Users can only see and modify their own sessions
DROP POLICY IF EXISTS "Users can view their own sessions" ON user_sessions;
CREATE POLICY "Users can view their own sessions"
  ON user_sessions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own sessions" ON user_sessions;
CREATE POLICY "Users can insert their own sessions"
  ON user_sessions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- ========================================
-- Step 5: Create Functions
-- ========================================

-- Function to automatically create user profile when new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, username, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', SPLIT_PART(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'display_name', SPLIT_PART(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update user profile updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at on profile changes
DROP TRIGGER IF EXISTS on_user_profile_updated ON user_profiles;
CREATE TRIGGER on_user_profile_updated
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ========================================
-- Step 6: Insert Sample Data
-- ========================================

-- Insert Lesson 1
INSERT INTO lessons (lesson_number, lesson_name, description) 
VALUES (1, 'Lesson 1', 'JLPT N5 Basic Vocabulary - Greetings, Family, Food, Verbs, Time, Places, Adjectives, Nature, Common Words')
ON CONFLICT DO NOTHING;

-- Get the lesson_id
DO $$
DECLARE
  lesson1_id INTEGER;
BEGIN
  SELECT id INTO lesson1_id FROM lessons WHERE lesson_number = 1;

  -- Insert Vocabulary (only if not already exists)
  INSERT INTO vocabulary (lesson_id, jp, hiragana, romaji, en, category) VALUES
  -- Greetings
  (lesson1_id, 'おはよう', 'おはよう', 'ohayou', 'good morning', 'Greetings'),
  (lesson1_id, 'こんにちは', 'こんにちは', 'konnichiwa', 'hello / good afternoon', 'Greetings'),
  (lesson1_id, 'こんばんは', 'こんばんは', 'konbanwa', 'good evening', 'Greetings'),
  (lesson1_id, 'ありがとう', 'ありがとう', 'arigatou', 'thank you', 'Greetings'),
  (lesson1_id, 'すみません', 'すみません', 'sumimasen', 'excuse me / sorry', 'Greetings'),
  (lesson1_id, 'さようなら', 'さようなら', 'sayounara', 'goodbye', 'Greetings'),
  
  -- Family
  (lesson1_id, '家族', 'かぞく', 'kazoku', 'family', 'Family'),
  (lesson1_id, '父', 'ちち', 'chichi', 'father (my)', 'Family'),
  (lesson1_id, '母', 'はは', 'haha', 'mother (my)', 'Family'),
  (lesson1_id, '兄', 'あに', 'ani', 'older brother (my)', 'Family'),
  (lesson1_id, '姉', 'あね', 'ane', 'older sister (my)', 'Family'),
  (lesson1_id, '弟', 'おとうと', 'otouto', 'younger brother', 'Family'),
  (lesson1_id, '妹', 'いもうと', 'imouto', 'younger sister', 'Family'),
  (lesson1_id, '子供', 'こども', 'kodomo', 'child', 'Family'),
  
  -- Food
  (lesson1_id, '水', 'みず', 'mizu', 'water', 'Food'),
  (lesson1_id, 'お茶', 'おちゃ', 'ocha', 'tea', 'Food'),
  (lesson1_id, 'コーヒー', 'コーヒー', 'koohii', 'coffee', 'Food'),
  (lesson1_id, '牛乳', 'ぎゅうにゅう', 'gyuunyuu', 'milk', 'Food'),
  (lesson1_id, 'ご飯', 'ごはん', 'gohan', 'rice / meal', 'Food'),
  (lesson1_id, 'パン', 'パン', 'pan', 'bread', 'Food'),
  (lesson1_id, '肉', 'にく', 'niku', 'meat', 'Food'),
  (lesson1_id, '魚', 'さかな', 'sakana', 'fish', 'Food'),
  (lesson1_id, '野菜', 'やさい', 'yasai', 'vegetable', 'Food'),
  (lesson1_id, '果物', 'くだもの', 'kudamono', 'fruit', 'Food'),
  
  -- Verbs
  (lesson1_id, '食べる', 'たべる', 'taberu', 'to eat', 'Verbs'),
  (lesson1_id, '飲む', 'のむ', 'nomu', 'to drink', 'Verbs'),
  (lesson1_id, '行く', 'いく', 'iku', 'to go', 'Verbs'),
  (lesson1_id, '来る', 'くる', 'kuru', 'to come', 'Verbs'),
  (lesson1_id, '見る', 'みる', 'miru', 'to see / watch', 'Verbs'),
  (lesson1_id, '聞く', 'きく', 'kiku', 'to listen / hear', 'Verbs'),
  (lesson1_id, '話す', 'はなす', 'hanasu', 'to speak', 'Verbs'),
  (lesson1_id, '読む', 'よむ', 'yomu', 'to read', 'Verbs'),
  (lesson1_id, '書く', 'かく', 'kaku', 'to write', 'Verbs'),
  (lesson1_id, '買う', 'かう', 'kau', 'to buy', 'Verbs'),
  (lesson1_id, 'する', 'する', 'suru', 'to do', 'Verbs'),
  (lesson1_id, '寝る', 'ねる', 'neru', 'to sleep', 'Verbs'),
  (lesson1_id, '起きる', 'おきる', 'okiru', 'to wake up', 'Verbs'),
  (lesson1_id, '働く', 'はたらく', 'hataraku', 'to work', 'Verbs'),
  (lesson1_id, '勉強する', 'べんきょうする', 'benkyou suru', 'to study', 'Verbs'),
  
  -- Time
  (lesson1_id, '今', 'いま', 'ima', 'now', 'Time'),
  (lesson1_id, '今日', 'きょう', 'kyou', 'today', 'Time'),
  (lesson1_id, '明日', 'あした', 'ashita', 'tomorrow', 'Time'),
  (lesson1_id, '昨日', 'きのう', 'kinou', 'yesterday', 'Time'),
  (lesson1_id, '毎日', 'まいにち', 'mainichi', 'every day', 'Time'),
  (lesson1_id, '朝', 'あさ', 'asa', 'morning', 'Time'),
  (lesson1_id, '昼', 'ひる', 'hiru', 'noon / daytime', 'Time'),
  (lesson1_id, '夜', 'よる', 'yoru', 'night', 'Time'),
  (lesson1_id, '時間', 'じかん', 'jikan', 'time', 'Time'),
  (lesson1_id, '月曜日', 'げつようび', 'getsuyoubi', 'Monday', 'Time'),
  
  -- Places
  (lesson1_id, '家', 'いえ / うち', 'ie / uchi', 'house / home', 'Places'),
  (lesson1_id, '学校', 'がっこう', 'gakkou', 'school', 'Places'),
  (lesson1_id, '会社', 'かいしゃ', 'kaisha', 'company', 'Places'),
  (lesson1_id, '駅', 'えき', 'eki', 'station', 'Places'),
  (lesson1_id, '店', 'みせ', 'mise', 'shop / store', 'Places'),
  (lesson1_id, 'レストラン', 'レストラン', 'resutoran', 'restaurant', 'Places'),
  (lesson1_id, '図書館', 'としょかん', 'toshokan', 'library', 'Places'),
  (lesson1_id, '病院', 'びょういん', 'byouin', 'hospital', 'Places'),
  (lesson1_id, '銀行', 'ぎんこう', 'ginkou', 'bank', 'Places'),
  
  -- Adjectives
  (lesson1_id, '大きい', 'おおきい', 'ookii', 'big', 'Adjectives'),
  (lesson1_id, '小さい', 'ちいさい', 'chiisai', 'small', 'Adjectives'),
  (lesson1_id, '新しい', 'あたらしい', 'atarashii', 'new', 'Adjectives'),
  (lesson1_id, '古い', 'ふるい', 'furui', 'old (things)', 'Adjectives'),
  (lesson1_id, '良い', 'いい / よい', 'ii / yoi', 'good', 'Adjectives'),
  (lesson1_id, '悪い', 'わるい', 'warui', 'bad', 'Adjectives'),
  (lesson1_id, '高い', 'たかい', 'takai', 'expensive / tall', 'Adjectives'),
  (lesson1_id, '安い', 'やすい', 'yasui', 'cheap', 'Adjectives'),
  (lesson1_id, '暑い', 'あつい', 'atsui', 'hot (weather)', 'Adjectives'),
  (lesson1_id, '寒い', 'さむい', 'samui', 'cold (weather)', 'Adjectives'),
  (lesson1_id, '難しい', 'むずかしい', 'muzukashii', 'difficult', 'Adjectives'),
  (lesson1_id, '易しい', 'やさしい', 'yasashii', 'easy', 'Adjectives'),
  (lesson1_id, '美味しい', 'おいしい', 'oishii', 'delicious', 'Adjectives'),
  (lesson1_id, '楽しい', 'たのしい', 'tanoshii', 'fun / enjoyable', 'Adjectives'),
  
  -- Nature
  (lesson1_id, '天気', 'てんき', 'tenki', 'weather', 'Nature'),
  (lesson1_id, '雨', 'あめ', 'ame', 'rain', 'Nature'),
  (lesson1_id, '雪', 'ゆき', 'yuki', 'snow', 'Nature'),
  (lesson1_id, '風', 'かぜ', 'kaze', 'wind', 'Nature'),
  (lesson1_id, '花', 'はな', 'hana', 'flower', 'Nature'),
  (lesson1_id, '山', 'やま', 'yama', 'mountain', 'Nature'),
  (lesson1_id, '川', 'かわ', 'kawa', 'river', 'Nature'),
  (lesson1_id, '海', 'うみ', 'umi', 'sea / ocean', 'Nature'),
  
  -- Common Words
  (lesson1_id, '人', 'ひと', 'hito', 'person', 'Common'),
  (lesson1_id, '友達', 'ともだち', 'tomodachi', 'friend', 'Common'),
  (lesson1_id, '先生', 'せんせい', 'sensei', 'teacher', 'Common'),
  (lesson1_id, '学生', 'がくせい', 'gakusei', 'student', 'Common'),
  (lesson1_id, '本', 'ほん', 'hon', 'book', 'Common'),
  (lesson1_id, '車', 'くるま', 'kuruma', 'car', 'Common'),
  (lesson1_id, '電車', 'でんしゃ', 'densha', 'train', 'Common'),
  (lesson1_id, '言葉', 'ことば', 'kotoba', 'word / language', 'Common'),
  (lesson1_id, 'お金', 'おかね', 'okane', 'money', 'Common'),
  (lesson1_id, '仕事', 'しごと', 'shigoto', 'work / job', 'Common')
  ON CONFLICT DO NOTHING;

END $$;

-- ========================================
-- Step 7: Verify Setup
-- ========================================

-- Check lessons
SELECT 'Lessons:' as table_name, COUNT(*) as count FROM lessons
UNION ALL
SELECT 'Vocabulary:', COUNT(*) FROM vocabulary
UNION ALL
SELECT 'User Profiles:', COUNT(*) FROM user_profiles
UNION ALL
SELECT 'User Progress:', COUNT(*) FROM user_progress
UNION ALL
SELECT 'User Sessions:', COUNT(*) FROM user_sessions;

-- Show vocabulary by category
SELECT category, COUNT(*) as count 
FROM vocabulary 
GROUP BY category 
ORDER BY category;
