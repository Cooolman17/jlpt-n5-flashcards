# 🔒 Security Best Practices

## ⚠️ CRITICAL: Files That Should NEVER Be in GitHub

### ❌ Never Commit:

1. **SQL Files** (`.sql`)
   - Database schemas
   - Migration scripts
   - Sample data inserts
   - Database dumps
   - **Why:** Exposes your database structure to potential attackers

2. **Environment Files** (`.env`, `.env.local`)
   - API keys
   - Database passwords
   - Service role keys
   - **Why:** These are secrets that give full access to your backend

3. **Configuration Files with Secrets**
   - `config.js` with API keys
   - `secrets.json`
   - `credentials.json`
   - **Why:** Contains sensitive authentication information

4. **Database Files** (`.db`, `.sqlite`)
   - Local database files
   - Database backups
   - **Why:** May contain user data and PII

---

## ✅ Safe to Commit (Public Repository)

### What's OK in Frontend Code:

1. **Supabase Anon/Public Key** ✅
   - This is the `SUPABASE_ANON_KEY`
   - **Why it's safe:** Designed to be public, protected by RLS
   - **Example:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

2. **Supabase Project URL** ✅
   - Your project URL like `https://xxxxx.supabase.co`
   - **Why it's safe:** Public endpoint, protected by authentication & RLS

3. **HTML/CSS/JavaScript** ✅
   - Frontend code
   - UI components
   - Client-side logic
   - **Why it's safe:** Runs in browser, users can see it anyway

---

## 🛡️ Current Project Security Status

### ✅ Properly Secured:

1. **Row Level Security (RLS) Enabled**
   - Users can only access their own data
   - Enforced at database level (can't bypass)

2. **Authentication Required**
   - Must be logged in to access flashcards
   - Session-based authentication

3. **SQL Files Ignored**
   - `.gitignore` updated to exclude `*.sql`
   - Database schema not in repository

4. **No Hardcoded Secrets**
   - Only public keys in code
   - Service role key NOT in code

### ⚠️ Things to Remember:

1. **Email in user_profiles**
   - Email is visible to all authenticated users (for potential social features)
   - If you want emails private, update RLS policy

2. **Public anon key is visible**
   - This is normal and expected
   - RLS policies protect the data

---

## 🔐 Supabase Key Types

### 1. Anon/Public Key (Safe in Frontend)
```javascript
// ✅ SAFE - Can be in public GitHub
const SUPABASE_ANON_KEY = 'eyJhbGc...';
```
- Used in frontend applications
- Limited permissions
- Protected by RLS policies
- **Visible to users** (that's OK!)

### 2. Service Role Key (NEVER in Frontend)
```javascript
// ❌ DANGER - Never commit this!
const SUPABASE_SERVICE_KEY = 'eyJhbGc...'; // This bypasses RLS!
```
- Has admin access
- Bypasses Row Level Security
- Should only be on server/backend
- **NEVER commit to GitHub**

---

## 📝 .gitignore Configuration

Your `.gitignore` now includes:

```gitignore
# SQL Files - Database schema and migrations
*.sql
*.db
*.sqlite
*.sqlite3
*.dump
*.backup

# Environment variables
.env
.env.local
.env.*.local

# Sensitive config files
config.js
config.json
secrets.json
credentials.json
```

---

## 🚀 Deployment Best Practices

### For GitHub Pages / Static Hosting:

1. **Use Environment Variables (if supported)**
   ```javascript
   // Not applicable for GitHub Pages, but good for other platforms
   const SUPABASE_URL = process.env.SUPABASE_URL;
   ```

2. **For GitHub Pages Specifically**
   - It's OK to have anon key in code
   - Make sure RLS is properly configured
   - Never commit service role key

3. **For Production Apps**
   - Use environment variables
   - Implement rate limiting
   - Add monitoring and logging
   - Enable email verification

---

## 🔍 How to Check What's Being Committed

Before committing:

```bash
# See what files will be committed
git status

# See actual changes
git diff

# Check if .sql files are ignored
git check-ignore *.sql
# Should output: *.sql (if properly ignored)
```

---

## 🆘 What If I Already Committed Secrets?

### If You Committed SQL Files:

1. **They're already public** - Assume attackers have seen them
2. **Remove from history:**
   ```bash
   # Remove file from Git history
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch *.sql" \
     --prune-empty --tag-name-filter cat -- --all
   
   # Force push (careful!)
   git push origin --force --all
   ```

3. **Rotate credentials** - Even though SQL files don't have passwords, it's good practice

### If You Committed API Keys:

1. **Immediately rotate them** in Supabase dashboard
2. **Remove from Git history** (as above)
3. **Add to .gitignore**
4. **Recommit without secrets**

---

## ✅ Pre-Commit Checklist

Before every `git commit`:

- [ ] No `.sql` files added
- [ ] No `.env` files added
- [ ] No service role keys in code
- [ ] Only anon key present (if needed)
- [ ] `.gitignore` is up to date
- [ ] Ran `git status` to verify

---

## 📚 Additional Resources

- [Supabase Security Docs](https://supabase.com/docs/guides/auth)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

---

## 🎯 Quick Reference

### ✅ Safe to Commit:
- HTML, CSS, JavaScript (frontend)
- README.md, documentation
- Anon/Public API keys (with RLS)
- Public project URLs

### ❌ Never Commit:
- `.sql` files
- `.env` files
- Service role keys
- Database passwords
- Private user data

---

**Remember: Once something is on GitHub, consider it public forever!**

Use `.gitignore` religiously and review your commits before pushing.
