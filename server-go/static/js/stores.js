/**
 * Alpine.js Stores - Migrated from Zustand
 * Provides auth and cart state management with localStorage persistence
 */

document.addEventListener('alpine:init', () => {

    // =====================
    // AUTH STORE
    // =====================
    Alpine.store('auth', {
        user: null,
        token: null,
        hasHydrated: false,

        init() {
            // Restore from localStorage
            try {
                const stored = localStorage.getItem('auth-storage');
                if (stored) {
                    const { state } = JSON.parse(stored);
                    this.user = state?.user || null;
                    this.token = state?.token || null;
                }
            } catch (e) {
                console.error('Failed to hydrate auth:', e);
            }
            this.hasHydrated = true;

            // Check auth validity
            if (this.token) {
                this.checkAuth();
            }
        },

        login(user, token) {
            this.user = user;
            this.token = token;
            this._persist();
        },

        logout() {
            this.user = null;
            this.token = null;
            localStorage.removeItem('auth-storage');
            window.location.href = '/';
        },

        async checkAuth() {
            if (!this.token) return;

            try {
                const response = await fetch('/api/user/profile', {
                    headers: {
                        'Authorization': `Bearer ${this.token}`,
                        'x-arf-secure-token': window.ArfSecurity.generateSecureHeader()
                    }
                });

                if (response.ok) {
                    const data = await response.json();
                    this.user = data;
                    this._persist();
                } else if (response.status === 401) {
                    this.logout();
                }
            } catch (error) {
                console.error('Auth check failed:', error);
            }
        },

        _persist() {
            localStorage.setItem('auth-storage', JSON.stringify({
                state: { user: this.user, token: this.token }
            }));
        },

        get isLoggedIn() {
            return !!this.user && !!this.token;
        },

        get isAdmin() {
            return this.user?.role === 'ADMIN' || this.user?.role === 'SUPER_ADMIN';
        }
    });

    // =====================
    // CART STORE
    // =====================
    Alpine.store('cart', {
        items: [],

        init() {
            // Restore from localStorage
            try {
                const stored = localStorage.getItem('cart-storage');
                if (stored) {
                    const { state } = JSON.parse(stored);
                    this.items = state?.items || [];
                }
            } catch (e) {
                console.error('Failed to hydrate cart:', e);
            }

            // Sync with server if logged in
            if (Alpine.store('auth').token) {
                this.fetchCart();
            }
        },

        async fetchCart() {
            const token = Alpine.store('auth').token;
            if (!token) return;

            try {
                const response = await fetch('/api/user/cart', {
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'x-arf-secure-token': window.ArfSecurity.generateSecureHeader()
                    }
                });

                if (response.ok) {
                    const data = await response.json();
                    this.items = data.map(ci => ({
                        id: ci.product.id,
                        name: ci.product.name,
                        price: ci.product.price * (1 - (ci.product.discount || 0) / 100),
                        quantity: ci.quantity,
                        image: ci.product.images?.[0]
                    }));
                    this._persist();
                }
            } catch (e) {
                console.error('Failed to sync cart:', e);
            }
        },

        async addItem(item) {
            const token = Alpine.store('auth').token;

            // Sync with server
            if (token) {
                try {
                    const encrypted = window.ArfSecurity.encryptPayload({
                        productId: item.id,
                        quantity: item.quantity
                    });

                    await fetch('/api/user/cart', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'Authorization': `Bearer ${token}`,
                            'x-arf-secure-token': window.ArfSecurity.generateSecureHeader()
                        },
                        body: JSON.stringify(encrypted)
                    });
                } catch (e) {
                    console.error('Failed to add to cart:', e);
                }
            }

            // Update local state
            const existing = this.items.find(i => i.id === item.id);
            if (existing) {
                existing.quantity += item.quantity;
            } else {
                this.items.push(item);
            }
            this._persist();
        },

        async removeItem(id) {
            const token = Alpine.store('auth').token;

            if (token) {
                try {
                    await fetch(`/api/user/cart/${id}`, {
                        method: 'DELETE',
                        headers: {
                            'Authorization': `Bearer ${token}`,
                            'x-arf-secure-token': window.ArfSecurity.generateSecureHeader()
                        }
                    });
                } catch (e) {
                    console.error('Failed to remove from cart:', e);
                }
            }

            this.items = this.items.filter(i => i.id !== id);
            this._persist();
        },

        async updateQuantity(id, quantity) {
            const token = Alpine.store('auth').token;

            // Optimistic update
            const item = this.items.find(i => i.id === id);
            if (item) {
                item.quantity = quantity;
                this._persist();
            }

            if (token) {
                try {
                    const encrypted = window.ArfSecurity.encryptPayload({ quantity });

                    await fetch(`/api/user/cart/${id}`, {
                        method: 'PUT',
                        headers: {
                            'Content-Type': 'application/json',
                            'Authorization': `Bearer ${token}`,
                            'x-arf-secure-token': window.ArfSecurity.generateSecureHeader()
                        },
                        body: JSON.stringify(encrypted)
                    });
                } catch (e) {
                    console.error('Failed to update quantity:', e);
                }
            }
        },

        clearCart() {
            this.items = [];
            this._persist();
        },

        _persist() {
            localStorage.setItem('cart-storage', JSON.stringify({
                state: { items: this.items }
            }));
        },

        get total() {
            return this.items.reduce((acc, item) => acc + (item.price * item.quantity), 0);
        },

        get count() {
            return this.items.length;
        }
    });
});
