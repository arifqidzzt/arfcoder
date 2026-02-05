/**
 * HTMX Configuration
 * Intercepts all requests to add security headers and encryption
 */

// Add security headers to ALL HTMX requests
htmx.on('htmx:configRequest', function (evt) {
    // 1. Add Authorization header if logged in
    const authStore = Alpine.store('auth');
    if (authStore && authStore.token) {
        evt.detail.headers['Authorization'] = `Bearer ${authStore.token}`;
    }

    // 2. Add security header (required for ALL requests)
    if (window.ArfSecurity) {
        evt.detail.headers['x-arf-secure-token'] = window.ArfSecurity.generateSecureHeader();
    }
});

// Handle POST/PUT/PATCH - encrypt body
htmx.on('htmx:beforeRequest', function (evt) {
    const method = evt.detail.requestConfig?.verb?.toUpperCase();

    if (['POST', 'PUT', 'PATCH'].includes(method)) {
        // Check if we have body params
        const params = evt.detail.requestConfig.parameters;

        if (params && Object.keys(params).length > 0 && window.ArfSecurity) {
            // Encrypt the parameters
            const encrypted = window.ArfSecurity.encryptPayload(params);

            if (encrypted) {
                // Replace parameters with encrypted array
                evt.detail.requestConfig.parameters = encrypted;

                // Set content type to JSON
                evt.detail.requestConfig.headers['Content-Type'] = 'application/json';
            }
        }
    }
});

// Handle 401 responses - auto logout
htmx.on('htmx:responseError', function (evt) {
    if (evt.detail.xhr.status === 401) {
        const authStore = Alpine.store('auth');
        if (authStore) {
            authStore.logout();
        }

        // Redirect to login if not already there
        if (!window.location.pathname.includes('/login')) {
            window.location.href = '/login';
        }
    }
});

// Loading indicator
htmx.on('htmx:beforeRequest', function (evt) {
    const target = evt.detail.target;
    if (target) {
        target.classList.add('htmx-loading');
    }
});

htmx.on('htmx:afterRequest', function (evt) {
    const target = evt.detail.target;
    if (target) {
        target.classList.remove('htmx-loading');
    }
});

// Handle form submissions
htmx.on('htmx:beforeSend', function (evt) {
    // Add loading state to buttons
    const trigger = evt.detail.elt;
    if (trigger && trigger.tagName === 'BUTTON') {
        trigger.disabled = true;
        trigger.dataset.originalText = trigger.innerHTML;
        trigger.innerHTML = '<span class="animate-spin inline-block w-4 h-4 border-2 border-white border-t-transparent rounded-full mr-2"></span>Memproses...';
    }
});

htmx.on('htmx:afterRequest', function (evt) {
    // Restore button state
    const trigger = evt.detail.elt;
    if (trigger && trigger.tagName === 'BUTTON' && trigger.dataset.originalText) {
        trigger.disabled = false;
        trigger.innerHTML = trigger.dataset.originalText;
        delete trigger.dataset.originalText;
    }
});

// Toast notifications (simple implementation)
window.showToast = function (message, type = 'success') {
    const toast = document.createElement('div');
    toast.className = `fixed bottom-4 right-4 px-6 py-3 rounded-xl shadow-lg z-50 transition-all transform translate-y-full opacity-0 ${type === 'success' ? 'bg-black text-white' :
            type === 'error' ? 'bg-red-500 text-white' :
                'bg-gray-800 text-white'
        }`;
    toast.textContent = message;
    document.body.appendChild(toast);

    // Animate in
    requestAnimationFrame(() => {
        toast.classList.remove('translate-y-full', 'opacity-0');
    });

    // Remove after 3 seconds
    setTimeout(() => {
        toast.classList.add('translate-y-full', 'opacity-0');
        setTimeout(() => toast.remove(), 300);
    }, 3000);
};
