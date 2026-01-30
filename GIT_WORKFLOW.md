# 📋 Git Workflow - Security Checklist

## 🚀 Safe Commit Workflow

### Before Every Commit:

```bash
# 1. Check what files are staged
git status

# 2. Review changes (look for secrets!)
git diff

# 3. Check if any .sql files are being added
git ls-files | grep -i "\.sql$"
# Should return nothing if properly gitignored

# 4. Add files (excluding .sql)
git add .

# 5. Verify .sql files are ignored
git status
# Should NOT see any .sql files

# 6. Commit
git commit -m "Your commit message"

# 7. Push
git push origin developer-staging
```

---

## ✅ Files TO Commit

```bash
# HTML files
git add *.html

# Documentation
git add *.md

# Config
git add .gitignore

# JavaScript/CSS (frontend only)
git add *.js
git add *.css
```

---

## ❌ Files NOT to Commit

```bash
# These should be gitignored automatically
*.sql          # Database schemas
*.env          # Environment variables
*.db           # Database files
*.sqlite       # SQLite databases
config.js      # If it contains secrets
secrets.json   # Any secrets file
```

---

## 🗂️ Current Repository Structure

### ✅ Should be in GitHub:
```
jlpt-n5-flashcards/
├── .gitignore               ✅ Commit
├── README.md                ✅ Commit
├── SECURITY.md              ✅ Commit
├── DATABASE_SETUP.md        ✅ Commit
├── AUTH_SETUP_GUIDE.md      ✅ Commit
├── TEST_RESULTS_AND_FIXES.md ✅ Commit
├── GITHUB_SETUP.md          ✅ Commit
├── index.html               ✅ Commit
├── login.html               ✅ Commit
├── greeting.html            ✅ Commit
└── flashcards.html          ✅ Commit
```

### ❌ Should NOT be in GitHub (gitignored):
```
jlpt-n5-flashcards/
├── setup-database.sql                    ❌ DO NOT COMMIT
├── setup-database-with-auth.sql          ❌ DO NOT COMMIT
├── migration-add-email-to-profiles.sql   ❌ DO NOT COMMIT
├── disable-email-confirmation.sql        ❌ DO NOT COMMIT
└── any-other-file.sql                    ❌ DO NOT COMMIT
```

**Note:** Keep these SQL files locally for your own use, but they're excluded from Git.

---

## 🔧 If You Need to Share SQL

### Option 1: Private Documentation
Create a private document (Google Docs, Notion, etc.) with SQL commands

### Option 2: Inline in Setup Guide
Include SQL snippets in `DATABASE_SETUP.md` (already done!)

### Option 3: Private Gist
Use a private GitHub Gist for SQL files

### ❌ Never: Public Repository
Don't put SQL files in public GitHub repos

---

## 🆘 Emergency: Removing Committed Secrets

If you accidentally committed `.sql` files or secrets:

### Step 1: Remove from latest commit
```bash
# If just committed (not pushed yet)
git reset HEAD~1
git add .gitignore
# Re-add only safe files
git add *.html *.md
git commit -m "Fix: removed SQL files"
```

### Step 2: Remove from Git history
```bash
# If already pushed (nuclear option)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch *.sql" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (WARNING: This rewrites history!)
git push origin --force --all
```

### Step 3: Verify
```bash
# Check git history for .sql files
git log --all --full-history -- "*.sql"
# Should show nothing
```

---

## 📊 Pre-Push Checklist

Before `git push`:

- [ ] Ran `git status` - no `.sql` files
- [ ] Ran `git diff` - no secrets visible
- [ ] Only HTML, CSS, JS, MD files staged
- [ ] `.gitignore` includes `*.sql`
- [ ] Commit message is descriptive
- [ ] All tests passing locally

---

## 🎯 Branch Strategy

### developer-staging (Development)
```bash
git checkout developer-staging
git add *.html *.md
git commit -m "Feature: Add progress tracking"
git push origin developer-staging
```

### main (Production)
```bash
# Only merge when tested
git checkout main
git merge developer-staging
git push origin main
```

---

## ⚡ Quick Commands

### Check what's being committed:
```bash
git diff --cached
```

### See ignored files:
```bash
git status --ignored
```

### List all SQL files (should be gitignored):
```bash
find . -name "*.sql" -not -path "./.git/*"
```

### Force refresh gitignore:
```bash
git rm -r --cached .
git add .
git commit -m "Refresh gitignore"
```

---

## 📝 Example Commit Messages

### ✅ Good:
```
git commit -m "Add user authentication system"
git commit -m "Fix: Username login now works"
git commit -m "Update: Progress tracking saves to database"
git commit -m "Docs: Add security guidelines"
```

### ❌ Bad (too vague):
```
git commit -m "updates"
git commit -m "fix"
git commit -m "changes"
```

---

## 🎓 Summary

### Remember:
1. **Always check** `git status` before committing
2. **Never commit** `.sql` files to public repos
3. **Use .gitignore** to automatically exclude sensitive files
4. **Review changes** with `git diff` before pushing
5. **Anon keys are OK** in frontend code (protected by RLS)

### Your SQL files are safe because:
- ✅ `.gitignore` excludes `*.sql`
- ✅ Database setup is documented in `DATABASE_SETUP.md`
- ✅ Developers can recreate the schema from docs
- ✅ No database structure exposed publicly

---

**Stay secure! 🔒**
