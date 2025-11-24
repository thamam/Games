import React, { useState, useEffect } from 'react';

const BANNER_DISMISSED_KEY = 'beta-banner-dismissed';

/**
 * Beta Banner Component
 *
 * Displays a dismissible banner informing users this is a beta version
 * where progress is saved locally on their device only.
 */
export const BetaBanner: React.FC = () => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    // Check if the banner was previously dismissed
    const wasDismissed = localStorage.getItem(BANNER_DISMISSED_KEY);
    if (!wasDismissed) {
      setIsVisible(true);
    }
  }, []);

  const handleDismiss = () => {
    localStorage.setItem(BANNER_DISMISSED_KEY, 'true');
    setIsVisible(false);
  };

  if (!isVisible) {
    return null;
  }

  return (
    <div style={styles.banner}>
      <div style={styles.content}>
        <span style={styles.text}>גרסת בטא: ההתקדמות נשמרת על מכשיר זה בלבד.</span>
        <button
          onClick={handleDismiss}
          style={styles.closeButton}
          aria-label="סגור הודעה"
        >
          ✕
        </button>
      </div>
    </div>
  );
};

const styles: { [key: string]: React.CSSProperties } = {
  banner: {
    backgroundColor: '#fef3c7',
    borderBottom: '2px solid #f59e0b',
    padding: '12px 16px',
    position: 'sticky',
    top: 0,
    zIndex: 1000,
  },
  content: {
    maxWidth: '1200px',
    margin: '0 auto',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: '16px',
  },
  text: {
    fontSize: '14px',
    fontWeight: '500',
    color: '#92400e',
    flex: 1,
  },
  closeButton: {
    background: 'none',
    border: 'none',
    fontSize: '20px',
    color: '#92400e',
    cursor: 'pointer',
    padding: '4px 8px',
    lineHeight: '1',
    transition: 'opacity 0.2s',
  },
};
