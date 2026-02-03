# 🔐 Authentication Setup Guide

## Overview

Your JLPT N5 Flashcards app now includes a complete authentication system with:
- User registration (sign up)
- User login with email or username
- Secure password authentication
- User-specific progress tracking
- Row Level Security (RLS) to protect user data

---

## 📋 Step-by-Step Setup

### Step 1: Configure Supabase Email Settings

1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Select your project
3. Go to **Authentication** → **Email Templates**
4. Ensure the following templates are configured:
   - **Confirm signup**: Enabled
   - **Magic Link**: Optional
   - **Change Email Address**: Enabled
   - **Reset Password**: Enabled

5. Go to **Authentication** → **Providers**
6. Ensure **Email** provider is enabled

### Step 2: Run the Updated Database Script

1. Go to **SQL Editor** in Supabase
2. Copy and paste the contents of `setup-database-with-auth.sql`
3. Click **Run** (or Ctrl/Cmd + Enter)

This will:
- Create all necessary tables (lessons, vocabulary, user_profiles, user_progress, user_sessions)
- Set up Row Level Security (RLS) policies
- Create triggers for automatic profile creation
- Insert sample vocabulary data

### Step 3: Verify Email Configuration (Important!)

By default, Supabase requires email confirmation. You have two options:

#### Option A: Enable Email Confirmation (Production - Recommended)

1. Go to **Authentication** → **Settings**
2. Under **Email Auth**:
   - ✅ Enable email confirmations
   - Set **Site URL**: `http://localhost:8000` (for development) or your production URL
3. When users sign up, they'll receive a confirmation email

#### Option B: Disable Email Confirmation (Development Only)

1. Go to **Authentication** → **Settings**
2. Under **Email Auth**:
   - ❌ Disable "Enable email confirmations"
3. Users can log in immediately after signup (no email required)

**For testing, use Option B. For production, use Option A.**

### Step 4: Test Your Authentication

1. Open `index.html` in a browser (remember to use a local server!)
2. You should be redirected to `login.html`
3. Click "Sign Up" tab
4. Create a test account:
   - Username: `testuser`
   - Email: `test@example.com`
   - Password: `password123`
5. Sign up and log in
6. You should be redirected to the greeting page!

---

## 🗄️ Database Structure

### New Tables

#### `user_profiles`
Stores user profile information
- `id` (UUID) - Links to auth.users
- `username` (TEXT, UNIQUE) - User's chosen username
- `display_name` (TEXT) - Display name
- `created_at`, `updated_at` (TIMESTAMP)

#### `user_progress`
Tracks each user's progress on vocabulary
- `id` (SERIAL)
- `user_id` (UUID) - Which user
- `vocabulary_id` (INTEGER) - Which word
- `status` (TEXT) - 'known', 'learning', or 'new'
- `last_reviewed` (TIMESTAMP)
- `review_count` (INTEGER)

#### `user_sessions`
Tracks study sessions for analytics
- `id` (SERIAL)
- `user_id` (UUID)
- `lesson_id` (INTEGER)
- `session_date` (TIMESTAMP)
- `cards_studied`, `cards_known`, `cards_learning` (INTEGER)
- `duration_minutes` (INTEGER)

---

## 🔒 Row Level Security (RLS) Policies

### What is RLS?

Row Level Security ensures that users can only see and modify their own data. It's enforced at the database level, so it's impossible to bypass.

### Policies Applied:

**Lessons & Vocabulary:**
- ✅ All authenticated users can READ all lessons and vocabulary
- ❌ Users cannot modify lessons or vocabulary

**User Profiles:**
- ✅ Users can view all profiles (for leaderboards, etc.)
- ✅ Users can only INSERT/UPDATE their own profile

**User Progress:**
- ✅ Users can only see their own progress
- ✅ Users can only modify their own progress
- ❌ Users cannot see other users' progress

**User Sessions:**
- ✅ Users can only see their own sessions
- ✅ Users can only create their own sessions

---

## 🔧 How Authentication Works

### 1. User Signs Up
```javascript
// User fills out signup form
supabaseClient.auth.signUp({
    email: email,
    password: password,
    options: {
        data: { username, display_name }
    }
})

// Trigger automatically creates user_profile record
```

### 2. User Logs In
```javascript
// User enters email/username and password
supabaseClient.auth.signInWithPassword({
    email: email,
    password: password
})

// Session is created and stored
```

### 3. Protected Pages Check Auth
```javascript
// On page load
const { data: { session } } = await supabaseClient.auth.getSession();

if (!session) {
    // Redirect to login
    window.location.href = 'login.html';
}
```

### 4. User Logs Out
```javascript
await supabaseClient.auth.signOut();
// Session is cleared
```

---

## 🌐 Application Flow

```
index.html (redirect)
    ↓
login.html
    ↓
[User logs in or signs up]
    ↓
greeting.html (protected - requires auth)
    ↓
flashcards.html (protected - requires auth)
```

---

## 🐛 Troubleshooting

### "User not found" error on login
**Solution:** Make sure you're using the correct email or username. Usernames are case-sensitive.

### Email confirmation not received
**Solution:**
1. Check spam folder
2. Verify email settings in Supabase → Authentication → Email Templates
3. For testing, disable email confirmation (see Step 3, Option B)

### "Failed to create account"
**Solution:**
1. Check if username is already taken
2. Ensure password is at least 6 characters
3. Check browser console for detailed error

### User can't see vocabulary
**Solution:**
1. Verify RLS policies are set up correctly
2. Check that user is actually logged in
3. Ensure vocabulary data exists in database

### Login page shows blank screen
**Solution:**
1. Check browser console for errors
2. Verify Supabase URL and ANON_KEY are correct
3. Make sure you're serving files through a web server (not file://)

---

## 🔑 Security Best Practices

### ✅ DO:
- Keep your Supabase ANON key public (it's designed for this)
- Use RLS policies to protect sensitive data
- Validate input on the client side
- Use HTTPS in production

### ❌ DON'T:
- Share your Supabase SERVICE_ROLE key publicly
- Store sensitive data in sessionStorage/localStorage
- Trust client-side validation alone
- Disable RLS in production

---

## 📊 Next Steps

Once authentication is working:

1. **Add password reset functionality**
   ```javascript
   await supabaseClient.auth.resetPasswordForEmail(email);
   ```

2. **Add user profile page**
   - Edit username/display name
   - View study statistics
   - See progress charts

3. **Implement progress saving**
   - Save which cards user knows
   - Track study sessions
   - Show study streaks

4. **Add social features**
   - Leaderboards
   - Study groups
   - Share progress

---

## 🆘 Need Help?

If you encounter issues:

1. Check the browser console (F12 → Console)
2. Check Supabase logs (Dashboard → Logs)
3. Verify your RLS policies (Dashboard → Authentication → Policies)
4. Test with email confirmation disabled first

---

## ✅ Verification Checklist

- [ ] Database tables created successfully
- [ ] RLS policies enabled
- [ ] Email settings configured
- [ ] Test user created successfully
- [ ] Test user can log in
- [ ] Test user can access greeting page
- [ ] Test user can start flashcards
- [ ] Logout works correctly
- [ ] Second user account is completely separate

---

**Your authentication system is ready! 🎉**
