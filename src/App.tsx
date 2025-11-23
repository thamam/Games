import React from 'react';
import { LanguageProvider } from './lib/i18n/LanguageContext';
import { Navigation } from './components/layout/Navigation';
import { BetaBanner } from './components/layout/BetaBanner';
import './App.css';

/**
 * Main App Component
 *
 * Hebrew-Only Beta Version:
 * - Wrapped in LanguageProvider (forces Hebrew/RTL)
 * - Includes BetaBanner at the top
 * - Includes Navigation (without language toggle)
 */
function App() {
  return (
    <LanguageProvider>
      <div className="app">
        <BetaBanner />
        <Navigation />
        <main className="main-content">
          <div className="container">
            <h2>ברוכים הבאים למשחקים לומדים!</h2>
            <p className="subtitle">גרסת בטא - למידה מהנה בעברית</p>

            <div className="welcome-card">
              <h3>🎮 התחל ללמוד היום</h3>
              <p>
                בחר משחק מהרשימה למעלה כדי להתחיל ללמוד עברית בדרך מהנה ואינטראקטיבית.
              </p>
              <p>
                <strong>שים לב:</strong> זוהי גרסת בטא. ההתקדמות שלך נשמרת רק על מכשיר זה.
              </p>
            </div>
          </div>
        </main>
      </div>
    </LanguageProvider>
  );
}

export default App;
