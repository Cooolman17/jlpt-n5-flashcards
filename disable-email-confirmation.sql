-- ========================================
-- Disable Email Confirmation (FOR TESTING ONLY)
-- ========================================
-- Run this in Supabase SQL Editor to allow users to login immediately after signup
-- without email confirmation

-- This is a MANUAL step you need to do in Supabase Dashboard:
-- 1. Go to Authentication → Settings → Email Auth
-- 2. UNCHECK "Enable email confirmations"
-- 3. Click Save

-- Alternatively, you can programmatically confirm existing users:
-- (Run this to confirm all existing unconfirmed users)

-- WARNING: Only use this for development/testing!
-- In production, you should require email confirmation for security.

-- ========================================
-- Auto-confirm all existing users (optional)
-- ========================================
-- This requires SERVICE_ROLE access, so you'll need to:
-- 1. Get your SERVICE_ROLE key from Settings → API → service_role (secret)
-- 2. Use it in your backend code (NEVER in frontend!)

-- For now, the easiest way for testing is:
-- Dashboard → Authentication → Settings → Email Auth → Disable "Enable email confirmations"

-- ========================================
-- Check current user confirmation status
-- ========================================
SELECT 
  id,
  email,
  email_confirmed_at,
  CASE 
    WHEN email_confirmed_at IS NULL THEN 'Not Confirmed'
    ELSE 'Confirmed'
  END as status,
  created_at
FROM auth.users
ORDER BY created_at DESC;
