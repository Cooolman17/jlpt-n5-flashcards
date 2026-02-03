# 🔄 Migration Guide - Structure Changes

## 📋 Changes Summary

### Database Changes:
1. ✅ `lessons` table: Removed `lesson_number` column
2. ✅ `user_profiles` table: Added `lesson_id` column (NOT NULL)
3. ✅ `vocabulary` table: Renamed `jp` → `displayWord`, `en` → `english`

### UI Changes:
1. ✅ Login page: Already shows "FlashCard Learning"
2. ✅ Greeting page: Shows lesson description dynamically
3. ✅ All logic updated to use new column names

---

## 🚀 Step-by-Step Migration

### Step 1: Run Database Migration

**In Supabase SQL Editor**, run this SQL:

```sql
-- ========================================
-- STEP 1: Update lessons table
-- ========================================
ALTER TABLE lessons DROP COLUMN IF EXISTS lesson_number;

-- ========================================
-- STEP 2: Update user_profiles table
-- ========================================
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS lesson_id INTEGER REFERENCES lessons(id);

-- Set default lesson for existing users
UPDATE user_profiles 
SET lesson_id = 1 
WHERE lesson_id IS NULL;

-- Make lesson_id NOT NULL
ALTER TABLE user_profiles 
ALTER COLUMN lesson_id SET NOT NULL;

-- Add index
CREATE INDEX IF NOT EXISTS idx_user_profiles_lesson_id ON user_profiles(lesson_id);

-- ========================================
-- STEP 3: Update vocabulary table
-- ========================================
ALTER TABLE vocabulary 
RENAME COLUMN jp TO displayWord;

ALTER TABLE vocabulary 
RENAME COLUMN en TO english;

-- ========================================
-- STEP 4: Update trigger function
-- ========================================
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

-- ========================================
-- STEP 5: Verify changes
-- ========================================
-- Check vocabulary columns
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'vocabulary'
ORDER BY ordinal_position;

-- Should show: id, lesson_id, displayWord, hiragana, romaji, english, category, created_at

-- Check user_profiles has lesson_id
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'user_profiles'
ORDER BY ordinal_position;

-- Should include: lesson_id

-- Check lessons doesn't have lesson_number
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'lessons'
ORDER BY ordinal_position;

-- Should show: id, lesson_name, description, created_at (NO lesson_number)

SELECT 'Migration completed!' as status;
```

### Step 2: Verify Data Integrity

Run these checks:

```sql
-- Check all users have lesson_id
SELECT 
  COUNT(*) as total_users,
  COUNT(lesson_id) as users_with_lesson
FROM user_profiles;
-- Both should be equal

-- Check vocabulary data is intact
SELECT 
  id,
  displayWord,
  hiragana,
  romaji,
  english,
  category
FROM vocabulary
LIMIT 5;
-- Should display properly with new column names

-- Check lessons still work
SELECT id, lesson_name, description
FROM lessons;
-- Should show lessons without lesson_number
```

### Step 3: Deploy Updated HTML Files

Upload these updated files to GitHub:
- ✅ `login.html` (includes lesson_id in signup)
- ✅ `greeting.html` (shows lesson description)
- ✅ `flashcards.html` (uses displayWord and english)

```bash
git add login.html greeting.html flashcards.html
git commit -m "Update: New database structure - lesson_id, displayWord, english"
git push origin developer-staging
```

### Step 4: Test Everything

#### Test 1: New User Signup
1. Go to login page
2. Create new account
3. Check Supabase → `user_profiles` table
4. Verify new user has `lesson_id = 1`

#### Test 2: Greeting Page
1. Login with test account
2. Should see "FlashCard Learning" title
3. Select a lesson from dropdown
4. Title should change to lesson name
5. Description should update

#### Test 3: Flashcards
1. Click "Start Learning"
2. Flashcards should display correctly
3. Front: Japanese word (displayWord)
4. Back: English translation (english)
5. Mark cards - should save to database

#### Test 4: Username Login
1. Logout
2. Login with username (not email)
3. Should work without errors

---

## 🔍 Troubleshooting

### Issue: "column jp does not exist"

**Cause:** Vocabulary table not migrated yet

**Solution:**
```sql
-- Check current column names
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'vocabulary';

-- If jp and en still exist, run:
ALTER TABLE vocabulary RENAME COLUMN jp TO displayWord;
ALTER TABLE vocabulary RENAME COLUMN en TO english;
```

### Issue: "column lesson_id does not exist" in user_profiles

**Cause:** user_profiles not migrated yet

**Solution:**
```sql
-- Add the column
ALTER TABLE user_profiles 
ADD COLUMN lesson_id INTEGER REFERENCES lessons(id);

-- Set default for existing users
UPDATE user_profiles SET lesson_id = 1 WHERE lesson_id IS NULL;

-- Make it required
ALTER TABLE user_profiles ALTER COLUMN lesson_id SET NOT NULL;
```

### Issue: Flashcards not displaying

**Cause:** JavaScript still using old column names

**Solution:** 
1. Clear browser cache (Ctrl+F5)
2. Verify you deployed updated `flashcards.html`
3. Check browser console for errors

### Issue: Lesson description not showing

**Cause:** Lessons missing description field

**Solution:**
```sql
-- Add descriptions to existing lessons
UPDATE lessons 
SET description = 'JLPT N5 Basic Vocabulary - Greetings, Family, Food, Verbs, and more'
WHERE id = 1;
```

---

## ✅ Verification Checklist

After migration, verify:

### Database:
- [ ] `lessons` table has NO `lesson_number` column
- [ ] `user_profiles` table HAS `lesson_id` column (NOT NULL)
- [ ] `vocabulary` table has `displayWord` and `english` columns
- [ ] All existing users have `lesson_id` set
- [ ] Trigger function updated to include `lesson_id`

### Frontend:
- [ ] Login page shows "FlashCard Learning"
- [ ] Signup passes `lesson_id` to metadata
- [ ] Greeting page displays lesson description
- [ ] Greeting page title updates when lesson selected
- [ ] Flashcards display Japanese words correctly
- [ ] Flashcards display English translations correctly

### Functionality:
- [ ] New user signup works
- [ ] User login works (email and username)
- [ ] Lesson selection updates description
- [ ] Flashcards load and display
- [ ] Progress saves correctly
- [ ] Sessions save correctly

---

## 📊 Expected Table Structures

### lessons
```
id              | SERIAL PRIMARY KEY
lesson_name     | TEXT NOT NULL
description     | TEXT
created_at      | TIMESTAMP
```

### vocabulary
```
id              | SERIAL PRIMARY KEY
lesson_id       | INTEGER (FK to lessons)
displayWord     | TEXT NOT NULL
hiragana        | TEXT NOT NULL
romaji          | TEXT NOT NULL
english         | TEXT NOT NULL
category        | TEXT NOT NULL
created_at      | TIMESTAMP
```

### user_profiles
```
id              | UUID (FK to auth.users)
username        | TEXT UNIQUE NOT NULL
email           | TEXT NOT NULL
display_name    | TEXT
lesson_id       | INTEGER NOT NULL (FK to lessons)
created_at      | TIMESTAMP
updated_at      | TIMESTAMP
```

---

## 🎯 What Changed in Code

### login.html
```javascript
// OLD
options: {
  data: {
    username: username,
    display_name: username
  }
}

// NEW
options: {
  data: {
    username: username,
    display_name: username,
    lesson_id: 1  // ✅ Added
  }
}
```

### greeting.html
```javascript
// OLD
.order('lesson_number', { ascending: true });

// NEW
.order('id', { ascending: true });

// NEW FEATURE: Dynamic lesson description
function updateLessonDescription() {
  const selectedOption = lessonSelect.options[lessonSelect.selectedIndex];
  const description = selectedOption.getAttribute('data-description');
  document.getElementById('lesson-description').textContent = description;
}
```

### flashcards.html
```javascript
// OLD
card.jp
card.en

// NEW
card.displayWord
card.english
```

---

## 🚀 Deployment

### 1. Commit Changes
```bash
git status
git add login.html greeting.html flashcards.html DATABASE_SETUP.md
git commit -m "Migration: Remove lesson_number, add lesson_id, rename jp/en columns"
```

### 2. Push to Staging
```bash
git push origin developer-staging
```

### 3. Test on Staging
- Visit your GitHub Pages URL
- Test all functionality
- Check browser console for errors

### 4. Merge to Main (when ready)
```bash
git checkout main
git merge developer-staging
git push origin main
```

---

## ✅ Migration Complete!

You've successfully:
- ✅ Removed `lesson_number` from lessons
- ✅ Added `lesson_id` to user_profiles
- ✅ Renamed vocabulary columns to `displayWord` and `english`
- ✅ Updated all UI to reflect changes
- ✅ Updated trigger functions
- ✅ Maintained data integrity

**All tests passing? You're ready to go! 🎉**
