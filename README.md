# 🎌 JLPT N5 Flashcards

A beautiful, interactive flashcard application for learning JLPT N5 Japanese vocabulary. Built with vanilla JavaScript and Supabase backend.

![JLPT N5 Flashcards](https://img.shields.io/badge/JLPT-N5-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

- 📚 **80+ Vocabulary Words** organized by category
- 🎴 **Interactive Flashcards** with flip animation
- 🎯 **Progress Tracking** (Known, Learning, Remaining)
- 📊 **Category Filtering** (Greetings, Family, Food, Verbs, Time, Places, Adjectives, Nature, Common)
- 🔄 **Shuffle Mode** for randomized practice
- 📱 **Responsive Design** - works on mobile, tablet, and desktop
- 🗄️ **Supabase Backend** for easy content management
- 🌐 **Multiple Lessons** support (expandable)

## 🎯 Categories Included

- **Greetings** - Basic daily greetings
- **Family** - Family member terms
- **Food** - Common food and drinks
- **Verbs** - Essential action verbs
- **Time** - Time-related words
- **Places** - Locations and buildings
- **Adjectives** - Descriptive words
- **Nature** - Weather and natural elements
- **Common** - Everyday vocabulary

## 🚀 Quick Start

### Prerequisites

- A modern web browser
- A Supabase account (free tier works!)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/jlpt-n5-flashcards.git
   cd jlpt-n5-flashcards
   ```

2. **Set up Supabase** (see [SETUP_GUIDE.md](SETUP_GUIDE.md))
   - Create a Supabase project
   - Run `setup-database.sql` in SQL Editor
   - Enable Row Level Security policies
   - Get your API credentials

3. **Configure the app**
   - Open `index.html`
   - Update `SUPABASE_URL` and `SUPABASE_ANON_KEY` with your credentials

4. **Run locally**
   ```bash
   # Using Python
   python -m http.server 8000
   
   # Or using Node.js
   npx http-server
   
   # Or use VS Code Live Server extension
   ```

5. **Open in browser**
   ```
   http://localhost:8000
   ```

## 📖 Usage

1. **Select a Lesson** from the dropdown (currently Lesson 1 available)
2. **Choose Type** - Vocabulary (Grammar coming soon!)
3. **Click "Start Learning"** to begin
4. **Click cards to flip** and see the English translation
5. **Mark cards** as "Still Learning" or "I Know This"
6. **Filter by category** or shuffle for random order

## 🗄️ Database Structure

### Tables

**lessons**
- `id` - Primary key
- `lesson_number` - Lesson number (1, 2, 3...)
- `lesson_name` - Display name
- `description` - Optional description

**vocabulary**
- `id` - Primary key
- `lesson_id` - Foreign key to lessons
- `jp` - Japanese word (kanji/kana)
- `hiragana` - Hiragana reading
- `romaji` - Romaji reading
- `en` - English translation
- `category` - Word category

## 🎨 Customization

### Adding New Lessons

```sql
-- Insert new lesson
INSERT INTO lessons (lesson_number, lesson_name, description) 
VALUES (2, 'Lesson 2', 'JLPT N5 Advanced Vocabulary');

-- Insert vocabulary
INSERT INTO vocabulary (lesson_id, jp, hiragana, romaji, en, category) 
VALUES (2, '単語', 'たんご', 'tango', 'word', 'Common');
```

### Styling

All styles are contained in the HTML files. Customize colors, fonts, and animations by editing the `<style>` sections.

## 🌐 Deployment

### Deploy to Netlify

1. Push your code to GitHub
2. Go to [Netlify](https://netlify.com)
3. Click "New site from Git"
4. Select your repository
5. Deploy!

### Deploy to Vercel

```bash
npm i -g vercel
vercel
```

### Deploy to GitHub Pages

1. Go to repository Settings → Pages
2. Source: Deploy from a branch
3. Branch: `main` → `/root`
4. Save

**Note:** Make sure your Supabase credentials are updated in the deployed files!

## 🔒 Security

- API keys are exposed in frontend code (this is normal for Supabase anon keys)
- Row Level Security (RLS) policies protect your data
- Read-only access is granted to public users
- No write permissions without authentication

## 🛠️ Tech Stack

- **Frontend**: Vanilla JavaScript, HTML5, CSS3
- **Backend**: Supabase (PostgreSQL)
- **Hosting**: Any static site hosting (Netlify, Vercel, GitHub Pages)

## 📝 To-Do

- [ ] Add Grammar lessons
- [ ] Add audio pronunciation
- [ ] Add spaced repetition algorithm
- [ ] Add user accounts and progress saving
- [ ] Add more JLPT levels (N4, N3, etc.)
- [ ] Add quiz mode
- [ ] Add dark mode
- [ ] Add offline support with Service Worker

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👏 Acknowledgments

- JLPT vocabulary sourced from official JLPT guidelines
- Inspired by traditional Japanese flashcard learning methods
- Built with ❤️ for Japanese language learners

## 📧 Contact

Project Link: [https://github.com/YOUR_USERNAME/jlpt-n5-flashcards](https://github.com/YOUR_USERNAME/jlpt-n5-flashcards)

---

**Happy Learning! がんばって！(Ganbatte!)** 🎌
