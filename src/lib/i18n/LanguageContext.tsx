import React, { createContext, useContext, useEffect, useState } from 'react';

/**
 * Hebrew-Only Beta Version
 *
 * This context enforces Hebrew language for all users.
 * Language detection and toggle functionality has been removed.
 */

type Language = 'he';

interface LanguageContextType {
  language: Language;
  dir: 'rtl';
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export const LanguageProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // Force Hebrew mode - no language detection, no toggles
  const [language] = useState<Language>('he');
  const dir = 'rtl'; // Always RTL for Hebrew

  useEffect(() => {
    // Set document direction to RTL
    document.documentElement.dir = dir;
    document.documentElement.lang = language;
  }, [language, dir]);

  return (
    <LanguageContext.Provider value={{ language, dir }}>
      {children}
    </LanguageContext.Provider>
  );
};

export const useLanguage = () => {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
};
