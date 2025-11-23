import React from 'react';

/**
 * Navigation Component
 *
 * Hebrew-Only Beta Version:
 * - Language toggle has been REMOVED
 * - Includes feedback link for bug reports
 * - Displays navigation links and user actions
 */
export const Navigation: React.FC = () => {
  return (
    <nav style={styles.nav}>
      <div style={styles.container}>
        {/* Logo / Brand */}
        <div style={styles.brand}>
          <h1 style={styles.logo}>משחקים לומדים</h1>
        </div>

        {/* Navigation Links */}
        <div style={styles.navLinks}>
          <a href="/" style={styles.link}>
            בית
          </a>
          <a href="/games" style={styles.link}>
            משחקים
          </a>
          <a href="/progress" style={styles.link}>
            התקדמות
          </a>
        </div>

        {/* User Actions */}
        <div style={styles.actions}>
          {/* Feedback Link */}
          <a
            href="mailto:support@learningisfun.com?subject=דיווח%20על%20תקלה"
            style={styles.feedbackLink}
            title="דיווח על תקלה או משוב"
          >
            <span style={styles.feedbackIcon}>💬</span>
            <span>דיווח על תקלה</span>
          </a>
        </div>
      </div>
    </nav>
  );
};

const styles: { [key: string]: React.CSSProperties } = {
  nav: {
    backgroundColor: '#1f2937',
    color: '#ffffff',
    padding: '16px 24px',
    boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)',
  },
  container: {
    maxWidth: '1200px',
    margin: '0 auto',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: '24px',
  },
  brand: {
    flex: '0 0 auto',
  },
  logo: {
    fontSize: '24px',
    fontWeight: 'bold',
    margin: 0,
    color: '#fbbf24',
  },
  navLinks: {
    display: 'flex',
    gap: '24px',
    flex: 1,
    justifyContent: 'center',
  },
  link: {
    color: '#ffffff',
    textDecoration: 'none',
    fontSize: '16px',
    fontWeight: '500',
    padding: '8px 12px',
    borderRadius: '4px',
    transition: 'background-color 0.2s',
  },
  actions: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
    flex: '0 0 auto',
  },
  feedbackLink: {
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
    color: '#fbbf24',
    textDecoration: 'none',
    fontSize: '14px',
    fontWeight: '500',
    padding: '8px 12px',
    borderRadius: '4px',
    border: '1px solid #fbbf24',
    transition: 'all 0.2s',
  },
  feedbackIcon: {
    fontSize: '16px',
  },
};
