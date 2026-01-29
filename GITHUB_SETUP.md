# GitHub Setup Guide

## 🎯 Complete Step-by-Step Instructions

### Method 1: Using GitHub Desktop (Easiest)

#### Step 1: Download GitHub Desktop
1. Go to https://desktop.github.com
2. Download and install for your OS

#### Step 2: Create Repository on GitHub.com
1. Go to https://github.com and log in
2. Click **"+"** (top right) → **"New repository"**
3. Fill in:
   - Repository name: `jlpt-n5-flashcards`
   - Description: "JLPT N5 Flashcard Learning App"
   - ✅ Public (or Private)
   - ✅ Add a README file
   - Add .gitignore: None (we'll add our own)
   - License: MIT
4. Click **"Create repository"**

#### Step 3: Clone with GitHub Desktop
1. On your new repository page, click **"Code"** → **"Open with GitHub Desktop"**
2. Choose where to save the project on your computer
3. Click **"Clone"**

#### Step 4: Add Your Files
1. Copy all these files to your cloned folder:
   - `index.html`
   - `flashcards.html`
   - `setup-database.sql`
   - `SETUP_GUIDE.md`
   - `README.md`
   - `.gitignore`

2. Your folder should look like:
   ```
   jlpt-n5-flashcards/
   ├── .git/
   ├── .gitignore
   ├── README.md
   ├── index.html
   ├── flashcards.html
   ├── setup-database.sql
   └── SETUP_GUIDE.md
   ```

#### Step 5: Commit and Push
1. Open GitHub Desktop
2. You'll see all your new files listed
3. In the bottom left:
   - Summary: `Initial commit - JLPT N5 Flashcard app`
   - Description: `Added flashcard interface and Supabase integration`
4. Click **"Commit to main"**
5. Click **"Push origin"**
6. Done! 🎉

---

### Method 2: Using Command Line (Git)

#### Step 1: Create Repository on GitHub.com
Same as Method 1, Step 2 above

#### Step 2: Clone Repository
```bash
# Navigate to your projects folder
cd ~/Documents/Projects  # or wherever you keep projects

# Clone the repository
git clone https://github.com/YOUR_USERNAME/jlpt-n5-flashcards.git

# Enter the directory
cd jlpt-n5-flashcards
```

#### Step 3: Add Your Files
Copy all the project files into this directory

#### Step 4: Commit and Push
```bash
# Check what files are new
git status

# Add all files
git add .

# Commit with a message
git commit -m "Initial commit - JLPT N5 Flashcard app with Supabase"

# Push to GitHub
git push origin main
```

---

### Method 3: Create Locally First, Then Push to GitHub

#### Step 1: Create Local Folder
```bash
# Create project folder
mkdir jlpt-n5-flashcards
cd jlpt-n5-flashcards

# Initialize git
git init

# Add your files here (copy all the HTML, SQL, MD files)

# Create first commit
git add .
git commit -m "Initial commit"
```

#### Step 2: Create Empty Repository on GitHub
1. Go to GitHub → New repository
2. Name: `jlpt-n5-flashcards`
3. **DO NOT** check "Add a README" (we already have one)
4. Click "Create repository"

#### Step 3: Link and Push
```bash
# Add GitHub as remote
git remote add origin https://github.com/YOUR_USERNAME/jlpt-n5-flashcards.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

## 📝 Daily Git Workflow

Once your repository is set up, here's how to work with it:

### Making Changes

```bash
# 1. Make your edits to files

# 2. Check what changed
git status

# 3. Add changed files
git add index.html    # Add specific file
# OR
git add .             # Add all changed files

# 4. Commit with a message
git commit -m "Add new vocabulary category"

# 5. Push to GitHub
git push
```

### Common Git Commands

```bash
# See what changed
git status

# See commit history
git log

# See what you changed (before committing)
git diff

# Undo changes to a file (before committing)
git checkout -- filename.html

# Create a new branch
git checkout -b feature/new-lesson

# Switch branches
git checkout main

# Pull latest changes from GitHub
git pull
```

---

## 🌿 Branching Strategy (Optional - For Larger Projects)

```bash
# Create a feature branch
git checkout -b feature/add-lesson-2

# Make your changes
# ... edit files ...

# Commit changes
git add .
git commit -m "Add Lesson 2 vocabulary"

# Push the branch
git push -u origin feature/add-lesson-2

# Go to GitHub and create a Pull Request
# After review, merge to main
```

---

## 🔄 Keeping Your Fork Updated (If You Forked)

```bash
# Add original repository as upstream
git remote add upstream https://github.com/ORIGINAL_OWNER/jlpt-n5-flashcards.git

# Fetch updates
git fetch upstream

# Merge updates into your main branch
git checkout main
git merge upstream/main

# Push to your fork
git push origin main
```

---

## 🚨 Common Issues & Solutions

### Issue: "Permission denied"
**Solution:** Set up SSH keys or use HTTPS with personal access token

### Issue: "Repository not found"
**Solution:** Check the repository URL is correct and you have access

### Issue: Merge conflicts
**Solution:**
```bash
# Open conflicted files, resolve conflicts manually
# Files will have markers like <<<<<<< HEAD

# After resolving
git add .
git commit -m "Resolved merge conflicts"
git push
```

### Issue: Accidentally committed sensitive data
**Solution:** 
```bash
# Remove from git history (careful!)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/file" \
  --prune-empty --tag-name-filter cat -- --all

# Force push
git push origin --force --all
```

---

## 📚 Useful Resources

- [GitHub Desktop Documentation](https://docs.github.com/en/desktop)
- [Git Documentation](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)

---

## ✅ Checklist

- [ ] Repository created on GitHub
- [ ] Files added to repository
- [ ] First commit made
- [ ] Code pushed to GitHub
- [ ] README looks good on GitHub
- [ ] .gitignore is working
- [ ] Repository is public/private as intended
- [ ] Supabase credentials NOT committed (they're in the code, which is OK for anon keys)

---

**You're all set! Happy coding! 🚀**
