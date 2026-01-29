-- ========================================
-- JLPT N5 Flashcards - Database Setup
-- ========================================
-- Run this in your Supabase SQL Editor

-- Step 1: Create tables (if not already created)
-- ========================================

CREATE TABLE IF NOT EXISTS lessons (
  id SERIAL PRIMARY KEY,
  lesson_number INTEGER NOT NULL,
  lesson_name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

CREATE TABLE IF NOT EXISTS vocabulary (
  id SERIAL PRIMARY KEY,
  lesson_id INTEGER REFERENCES lessons(id),
  jp TEXT NOT NULL,
  hiragana TEXT NOT NULL,
  romaji TEXT NOT NULL,
  en TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Step 2: Insert Lesson 1
-- ========================================

INSERT INTO lessons (lesson_number, lesson_name, description) 
VALUES (1, 'Lesson 1', 'JLPT N5 Basic Vocabulary - Greetings, Family, Food, Verbs, Time, Places, Adjectives, Nature, Common Words');

-- Step 3: Insert Vocabulary for Lesson 1
-- ========================================

-- Get the lesson_id (should be 1 if this is your first lesson)
-- If you need to find it: SELECT id FROM lessons WHERE lesson_number = 1;

-- Greetings
INSERT INTO vocabulary (lesson_id, jp, hiragana, romaji, en, category) VALUES
(1, 'おはよう', 'おはよう', 'ohayou', 'good morning', 'Greetings'),
(1, 'こんにちは', 'こんにちは', 'konnichiwa', 'hello / good afternoon', 'Greetings'),
(1, 'こんばんは', 'こんばんは', 'konbanwa', 'good evening', 'Greetings'),
(1, 'ありがとう', 'ありがとう', 'arigatou', 'thank you', 'Greetings'),
(1, 'すみません', 'すみません', 'sumimasen', 'excuse me / sorry', 'Greetings'),
(1, 'さようなら', 'さようなら', 'sayounara', 'goodbye', 'Greetings');

-- Family
INSERT INTO vocabulary (lesson_id, jp, hiragana, romaji, en, category) VALUES
(1, '家族', 'かぞく', 'kazoku', 'family', 'Family'),
(1, '父', 'ちち', 'chichi', 'father (my)', 'Family'),
(1, '母', 'はは', 'haha', 'mother (my)', 'Family'),
(1, '兄', 'あに', 'ani', 'older brother (my)', 'Family'),
(1, '姉', 'あね', 'ane', 'older sister (my)', 'Family'),
(1, '弟', 'おとうと', 'otouto', 'younger brother', 'Family'),
(1, '妹', 'いもうと', 'imouto', 'younger sister', 'Family'),
(1, '子供', 'こども', 'kodomo', 'child', 'Family');

-- Food
INSERT INTO vocabulary (lesson_id, jp, hiragana, romaji, en, category) VALUES
(1, '水', 'みず', 'mizu', 'water', 'Food'),
(1, 'お茶', 'おちゃ', 'ocha', 'tea', 'Food'),
(1, 'コーヒー', 'コーヒー', 'koohii', 'coffee', 'Food'),
(1, '牛乳', 'ぎゅうにゅう', 'gyuunyuu', 'milk', 'Food'),
(1, 'ご飯', 'ごはん', 'gohan', 'rice / meal', 'Food'),
(1, 'パン', 'パン', 'pan', 'bread', 'Food'),
(1, '肉', 'にく', 'niku', 'meat', 'Food'),
(1, '魚', 'さかな', 'sakana', 'fish', 'Food'),
(1, '野菜', 'やさい', 'yasai', 'vegetable', 'Food'),
(1, '果物', 'くだもの', 'kudamono', 'fruit', 'Food');

-- Verbs
INSERT INTO vocabulary (lesson_id, jp, hiragana, romaji, en, category) VALUES
(1, '食べる', 'たべる', 'taberu', 'to eat', 'Verbs'),
(1, '飲む', 'のむ', 'nomu', 'to drink', 'Verbs'),
(1, '行く', 'いく', 'iku', 'to go', 'Verbs'),
(1, '来る', 'くる', 'kuru', 'to come', 'Verbs'),
(1, '見る', 'みる', 'miru', 'to see / watch', 'Verbs'),
(1, '聞く', 'きく', 'kiku', 'to listen / hear', 'Verbs'),
(1, '話す', 'はなす', 'hanasu', 'to speak', 'Verbs'),
(1, '読む', 'よむ', 'yomu', 'to read', 'Verbs'),
(1, '書く', 'かく', 'kaku', 'to write', 'Verbs'),
(1, '買う', 'かう', 'kau', 'to buy', 'Verbs'),
(1, 'する', 'する', 'suru', 'to do', 'Verbs'),
(1, '寝る', 'ねる', 'neru', 'to sleep', 'Verbs'),
(1, '起きる', 'おきる', 'okiru', 'to wake up', 'Verbs'),
(1, '働く', 'はたらく', 'hataraku', 'to work', 'Verbs'),
(1, '勉強する', 'べんきょうする', 'benkyou suru', 'to study', 'Verbs');

-- Time
INSERT INTO vocabulary (lesson_id, jp, hiragana, romaji, en, category) VALUES
(1, '今', 'いま', 'ima', 'now', 'Time'),
(1, '今日', 'きょう', 'kyou', 'today', 'Time'),
(1, '明日', 'あした', 'ashita', 'tomorrow', 'Time'),
(1, '昨日', 'きのう', 'kinou', 'yesterday', 'Time'),
(1, '毎日', 'まいにち', 'mainichi', 'every day', 'Time'),
(1, '朝', 'あさ', 'asa', 'morning', 'Time'),
(1, '昼', 'ひる', 'hiru', 'noon / daytime', 'Time'),
(1, '夜', 'よる', 'yoru', 'night', 'Time'),
(1, '時間', 'じかん', 'jikan', 'time', 'Time'),
(1, '月曜日', 'げつようび', 'getsuyoubi', 'Monday', 'Time');

-- Places
INSERT INTO vocabulary (lesson_id, jp, hiragana, romaji, en, category) VALUES
(1, '家', 'いえ / うち', 'ie / uchi', 'house / home', 'Places'),
(1, '学校', 'がっこう', 'gakkou', 'school', 'Places'),
(1, '会社', 'かいしゃ', 'kaisha', 'company', 'Places'),
(1, '駅', 'えき', 'eki', 'station', 'Places'),
(1, '店', 'みせ', 'mise', 'shop / store', 'Places'),
(1, 'レストラン', 'レストラン', 'resutoran', 'restaurant', 'Places'),
(1, '図書館', 'としょかん', 'toshokan', 'library', 'Places'),
(1, '病院', 'びょういん', 'byouin', 'hospital', 'Places'),
(1, '銀行', 'ぎんこう', 'ginkou', 'bank', 'Places');

-- Adjectives
INSERT INTO vocabulary (lesson_id, jp, hiragana, romaji, en, category) VALUES
(1, '大きい', 'おおきい', 'ookii', 'big', 'Adjectives'),
(1, '小さい', 'ちいさい', 'chiisai', 'small', 'Adjectives'),
(1, '新しい', 'あたらしい', 'atarashii', 'new', 'Adjectives'),
(1, '古い', 'ふるい', 'furui', 'old (things)', 'Adjectives'),
(1, '良い', 'いい / よい', 'ii / yoi', 'good', 'Adjectives'),
(1, '悪い', 'わるい', 'warui', 'bad', 'Adjectives'),
(1, '高い', 'たかい', 'takai', 'expensive / tall', 'Adjectives'),
(1, '安い', 'やすい', 'yasui', 'cheap', 'Adjectives'),
(1, '暑い', 'あつい', 'atsui', 'hot (weather)', 'Adjectives'),
(1, '寒い', 'さむい', 'samui', 'cold (weather)', 'Adjectives'),
(1, '難しい', 'むずかしい', 'muzukashii', 'difficult', 'Adjectives'),
(1, '易しい', 'やさしい', 'yasashii', 'easy', 'Adjectives'),
(1, '美味しい', 'おいしい', 'oishii', 'delicious', 'Adjectives'),
(1, '楽しい', 'たのしい', 'tanoshii', 'fun / enjoyable', 'Adjectives');

-- Nature
INSERT INTO vocabulary (lesson_id, jp, hiragana, romaji, en, category) VALUES
(1, '天気', 'てんき', 'tenki', 'weather', 'Nature'),
(1, '雨', 'あめ', 'ame', 'rain', 'Nature'),
(1, '雪', 'ゆき', 'yuki', 'snow', 'Nature'),
(1, '風', 'かぜ', 'kaze', 'wind', 'Nature'),
(1, '花', 'はな', 'hana', 'flower', 'Nature'),
(1, '山', 'やま', 'yama', 'mountain', 'Nature'),
(1, '川', 'かわ', 'kawa', 'river', 'Nature'),
(1, '海', 'うみ', 'umi', 'sea / ocean', 'Nature');

-- Common Words
INSERT INTO vocabulary (lesson_id, jp, hiragana, romaji, en, category) VALUES
(1, '人', 'ひと', 'hito', 'person', 'Common'),
(1, '友達', 'ともだち', 'tomodachi', 'friend', 'Common'),
(1, '先生', 'せんせい', 'sensei', 'teacher', 'Common'),
(1, '学生', 'がくせい', 'gakusei', 'student', 'Common'),
(1, '本', 'ほん', 'hon', 'book', 'Common'),
(1, '車', 'くるま', 'kuruma', 'car', 'Common'),
(1, '電車', 'でんしゃ', 'densha', 'train', 'Common'),
(1, '言葉', 'ことば', 'kotoba', 'word / language', 'Common'),
(1, 'お金', 'おかね', 'okane', 'money', 'Common'),
(1, '仕事', 'しごと', 'shigoto', 'work / job', 'Common');

-- ========================================
-- Verify data
-- ========================================

-- Check lessons
SELECT * FROM lessons;

-- Check vocabulary count
SELECT category, COUNT(*) as count 
FROM vocabulary 
WHERE lesson_id = 1 
GROUP BY category 
ORDER BY category;

-- Total vocabulary count for Lesson 1
SELECT COUNT(*) as total_vocabulary FROM vocabulary WHERE lesson_id = 1;
