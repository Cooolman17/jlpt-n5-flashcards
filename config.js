// ========================================
// SHARED CONFIGURATION
// ========================================
// Single source of truth for app configuration

const CONFIG = {
    SUPABASE: {
        URL: 'https://xjsrxzxrbzogeidqcozp.supabase.co',
        ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhqc3J4enhyYnpvZ2VpZHFjb3pwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2ODk3MzIsImV4cCI6MjA4NTI2NTczMn0.fYf40PoX4y7UuC6kPBAvPdar99KfSXdKLKeflGSBXKA'
    },
    
    DEFAULTS: {
        LESSON_ID: 1,
        REDIRECT_DELAY: 1000
    },
    
    VALIDATION: {
        USERNAME_PATTERN: /^[a-zA-Z0-9_]{3,20}$/,
        USERNAME_MIN_LENGTH: 3,
        USERNAME_MAX_LENGTH: 20,
        PASSWORD_MIN_LENGTH: 6,
        EMAIL_PATTERN: /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    },
    
    ROUTES: {
        LOGIN: 'login.html',
        GREETING: 'greeting.html',
        FLASHCARDS: 'flashcards.html'
    }
};

// Initialize Supabase client
const { createClient } = supabase;
const supabaseClient = createClient(CONFIG.SUPABASE.URL, CONFIG.SUPABASE.ANON_KEY);

// ========================================
// SHARED UTILITIES
// ========================================

const UI = {
    showError(message, elementId = 'error-message') {
        const element = document.getElementById(elementId);
        if (element) {
            element.textContent = message;
            element.classList.add('show');
        }
    },
    
    hideError(elementId = 'error-message') {
        const element = document.getElementById(elementId);
        if (element) {
            element.classList.remove('show');
        }
    },
    
    showSuccess(message, elementId = 'success-message') {
        const element = document.getElementById(elementId);
        if (element) {
            element.textContent = message;
            element.classList.add('show');
        }
    },
    
    hideSuccess(elementId = 'success-message') {
        const element = document.getElementById(elementId);
        if (element) {
            element.classList.remove('show');
        }
    },
    
    showLoading(elementId = 'loading') {
        const element = document.getElementById(elementId);
        if (element) element.style.display = 'block';
        
        // Disable buttons
        document.querySelectorAll('button[type="submit"]').forEach(btn => {
            btn.disabled = true;
        });
    },
    
    hideLoading(elementId = 'loading') {
        const element = document.getElementById(elementId);
        if (element) element.style.display = 'none';
        
        // Re-enable buttons
        document.querySelectorAll('button[type="submit"]').forEach(btn => {
            btn.disabled = false;
        });
    }
};

const Validator = {
    isValidEmail(email) {
        return CONFIG.VALIDATION.EMAIL_PATTERN.test(email);
    },
    
    isValidUsername(username) {
        return CONFIG.VALIDATION.USERNAME_PATTERN.test(username);
    },
    
    isValidPassword(password) {
        return password.length >= CONFIG.VALIDATION.PASSWORD_MIN_LENGTH;
    },
    
    passwordsMatch(password, confirm) {
        return password === confirm;
    }
};

const Auth = {
    async getSession() {
        const { data: { session } } = await supabaseClient.auth.getSession();
        return session;
    },
    
    async requireAuth() {
        const session = await this.getSession();
        if (!session) {
            window.location.href = CONFIG.ROUTES.LOGIN;
            return null;
        }
        return session.user;
    },
    
    async signOut() {
        const { error } = await supabaseClient.auth.signOut();
        if (error) throw error;
        sessionStorage.clear();
        window.location.href = CONFIG.ROUTES.LOGIN;
    }
};
