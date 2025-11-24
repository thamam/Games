# משחקים לומדים (Hebrew Learning Games)

## Hebrew-Only Beta Version 🇮🇱

This is a **Hebrew-only beta** of our educational games platform. The application is locked to Hebrew language with full RTL (Right-to-Left) support.

### Features

✅ **Hebrew-Only Interface** - No language toggle, all users see Hebrew
✅ **RTL Support** - Full right-to-left layout and text direction
✅ **Beta Banner** - Dismissible notice about local-only progress storage
✅ **Feedback System** - Direct bug/feedback reporting via email
✅ **Guest Mode** - Progress saved locally using browser localStorage

### Story 17: Beta Launch Prep - Completed ✓

**Implemented Features:**

1. **Forced Hebrew Mode** (`src/lib/i18n/LanguageContext.tsx`)
   - Default language locked to Hebrew (`'he'`)
   - Browser language detection removed
   - Document `dir` attribute always set to `'rtl'`

2. **Language Toggle Removed** (`src/components/layout/Navigation.tsx`)
   - No EN/HE switcher in UI
   - Clean navigation with links and feedback option

3. **Beta Banner Added** (`src/components/layout/BetaBanner.tsx`)
   - Hebrew text: "גרסת בטא: ההתקדמות נשמרת על מכשיר זה בלבד."
   - Dismissible with localStorage persistence
   - Appears at top of page

4. **Feedback Link Added** (`src/components/layout/Navigation.tsx`)
   - Label: "דיווח על תקלה" (Report a bug)
   - Icon: 💬
   - Opens: `mailto:support@learningisfun.com`

### Getting Started

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Tech Stack

- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **Hebrew (עברית)** - Primary and only language

### Testing the Beta

To verify the Hebrew-only beta setup:

1. **Clear localStorage**: Open DevTools → Application → Local Storage → Clear All
2. **Refresh the page**
3. **Expected behavior**:
   - ✅ Interface displays in Hebrew with RTL layout
   - ✅ NO language toggle visible in navigation
   - ✅ Beta banner appears at top (first visit)
   - ✅ Feedback link visible in navigation

### Project Structure

```
Games/
├── src/
│   ├── components/
│   │   └── layout/
│   │       ├── BetaBanner.tsx      # Beta notice banner
│   │       └── Navigation.tsx      # Main nav (no lang toggle)
│   ├── lib/
│   │   └── i18n/
│   │       └── LanguageContext.tsx # Hebrew-only context
│   ├── App.tsx                     # Main app component
│   ├── App.css                     # App styles (RTL-aware)
│   └── main.tsx                    # Entry point
├── index.html                      # HTML (lang="he" dir="rtl")
├── package.json
└── vite.config.ts
```

### Contact

For bug reports or feedback:
📧 support@learningisfun.com

---

**Made with ❤️ for Hebrew learners**