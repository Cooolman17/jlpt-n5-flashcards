-- ========================================
-- Migration: Add email to user_profiles
-- ========================================
-- Run this to update your existing database

-- Step 1: Add email column if it doesn't exist
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS email TEXT;

-- Step 2: Update existing profiles with email from auth.users
UPDATE user_profiles up
SET email = au.email
FROM auth.users au
WHERE up.id = au.id
AND up.email IS NULL;

-- Step 3: Make email NOT NULL after backfilling
ALTER TABLE user_profiles 
ALTER COLUMN email SET NOT NULL;

-- Step 4: Update the trigger function to include email
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, username, email, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', SPLIT_PART(NEW.email, '@', 1)),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', SPLIT_PART(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Verify the update
SELECT id, username, email, display_name 
FROM user_profiles 
ORDER BY created_at DESC;
