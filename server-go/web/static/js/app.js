/**
 * Main Application JavaScript
 * Alpine.js Stores and Components
 */

// ========================================
// TOAST NOTIFICATION SYSTEM
// ========================================
function showToast(message, type = 'info') {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;

    container.appendChild(toast);

    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateY(10px)';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

window.showToast = showToast;

// ========================================
// FORMAT HELPERS
// ========================================
function formatPrice(price) {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0
    }).format(price);
}

function formatDate(dateString) {
    return new Date(dateString).toLocaleDateString('id-ID', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

function formatTime(dateString) {
    return new Date(dateString).toLocaleTimeString('id-ID', {
        hour: '2-digit',
        minute: '2-digit'
    });
}

window.formatPrice = formatPrice;
window.formatDate = formatDate;
window.formatTime = formatTime;

// ========================================
// ALPINE.JS - MAIN APP STATE
// ========================================
function appState() {
    return {
        user: null,
        token: null,
        cart: {
            items: [],
            get total() {
                return this.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
            },
            get count() {
                return this.items.length;
            }
        },
        hasHydrated: false,

        async init() {
            // Load auth state from localStorage
            this.loadAuthState();
            // Load cart state from localStorage
            this.loadCartState();
            this.hasHydrated = true;

            // Check auth validity
            if (this.token) {
                await this.checkAuth();
            }
        },

        loadAuthState() {
            try {
                const authStorage = localStorage.getItem('auth-storage');
                if (authStorage) {
                    const parsed = JSON.parse(authStorage);
                    this.user = parsed.state?.user || null;
                    this.token = parsed.state?.token || null;
                }
            } catch (e) {
                console.error('Error loading auth state:', e);
            }
        },

        saveAuthState() {
            localStorage.setItem('auth-storage', JSON.stringify({
                state: { user: this.user, token: this.token }
            }));
        },

        loadCartState() {
            try {
                const cartStorage = localStorage.getItem('cart-storage');
                if (cartStorage) {
                    const parsed = JSON.parse(cartStorage);
                    this.cart.items = parsed.state?.items || [];
                }
            } catch (e) {
                console.error('Error loading cart state:', e);
            }
        },

        saveCartState() {
            localStorage.setItem('cart-storage', JSON.stringify({
                state: { items: this.cart.items }
            }));
        },

        async checkAuth() {
            if (!this.token) return;
            try {
                const data = await api.get('/user/profile');
                this.user = data;
                this.saveAuthState();
            } catch (error) {
                console.error('Auth check failed:', error);
                this.logout();
            }
        },

        async login(email, password) {
            try {
                const data = await api.post('/auth/login', { email, password });
                if (data.requiresOTP) {
                    return { requiresOTP: true, userId: data.userId };
                }
                this.user = data.user;
                this.token = data.token;
                this.saveAuthState();
                showToast('Login berhasil!', 'success');

                // Sync cart after login
                await this.syncCart();

                return { success: true };
            } catch (error) {
                showToast(error.message || 'Login gagal', 'error');
                return { success: false, error: error.message };
            }
        },

        async register(name, email, password) {
            try {
                const data = await api.post('/auth/register', { name, email, password });
                showToast('Registrasi berhasil! Silakan verifikasi email.', 'success');
                return { success: true, userId: data.userId };
            } catch (error) {
                showToast(error.message || 'Registrasi gagal', 'error');
                return { success: false, error: error.message };
            }
        },

        logout() {
            this.user = null;
            this.token = null;
            this.cart.items = [];
            localStorage.removeItem('auth-storage');
            localStorage.removeItem('cart-storage');
            showToast('Berhasil keluar', 'info');
        },

        // Cart Methods
        async addToCart(product, quantity = 1) {
            const existingIndex = this.cart.items.findIndex(item => item.id === product.id);

            if (existingIndex >= 0) {
                this.cart.items[existingIndex].quantity += quantity;
            } else {
                this.cart.items.push({
                    id: product.id,
                    name: product.name,
                    price: product.discountedPrice || product.price,
                    image: product.images?.[0] || '',
                    quantity: quantity
                });
            }

            this.saveCartState();

            // Sync with server if logged in
            if (this.token) {
                try {
                    await api.post('/user/cart', { productId: product.id, quantity });
                } catch (e) {
                    console.error('Failed to sync cart:', e);
                }
            }

            showToast('Produk ditambahkan ke keranjang', 'success');
        },

        async updateCartItem(productId, quantity) {
            const index = this.cart.items.findIndex(item => item.id === productId);
            if (index >= 0) {
                if (quantity <= 0) {
                    this.cart.items.splice(index, 1);
                } else {
                    this.cart.items[index].quantity = quantity;
                }
                this.saveCartState();

                if (this.token) {
                    try {
                        await api.put('/user/cart', { productId, quantity });
                    } catch (e) {
                        console.error('Failed to update cart:', e);
                    }
                }
            }
        },

        async removeFromCart(productId) {
            this.cart.items = this.cart.items.filter(item => item.id !== productId);
            this.saveCartState();

            if (this.token) {
                try {
                    await api.delete(`/user/cart/${productId}`);
                } catch (e) {
                    console.error('Failed to remove from cart:', e);
                }
            }

            showToast('Produk dihapus dari keranjang', 'info');
        },

        clearCart() {
            this.cart.items = [];
            this.saveCartState();
        },

        async syncCart() {
            if (!this.token) return;
            try {
                const data = await api.get('/user/cart');
                if (data && data.items) {
                    this.cart.items = data.items.map(item => ({
                        id: item.productId,
                        name: item.product?.name || '',
                        price: item.product?.discountedPrice || item.product?.price || 0,
                        image: item.product?.images?.[0] || '',
                        quantity: item.quantity
                    }));
                    this.saveCartState();
                }
            } catch (e) {
                console.error('Failed to sync cart:', e);
            }
        }
    };
}

// ========================================
// ALPINE.JS - ADMIN STATE
// ========================================
function adminState() {
    return {
        user: null,
        token: null,
        sidebarOpen: false,

        async init() {
            this.loadAuthState();
            if (this.token) {
                await this.checkAuth();
            }
        },

        loadAuthState() {
            try {
                const authStorage = localStorage.getItem('auth-storage');
                if (authStorage) {
                    const parsed = JSON.parse(authStorage);
                    this.user = parsed.state?.user || null;
                    this.token = parsed.state?.token || null;
                }
            } catch (e) {
                console.error('Error loading auth state:', e);
            }
        },

        async checkAuth() {
            if (!this.token) {
                window.location.href = '/login';
                return;
            }
            try {
                const data = await api.get('/user/profile');
                this.user = data;

                // Check admin role
                if (data.role !== 'ADMIN' && data.role !== 'SUPER_ADMIN') {
                    window.location.href = '/';
                }
            } catch (error) {
                console.error('Auth check failed:', error);
                window.location.href = '/login';
            }
        },

        logout() {
            localStorage.removeItem('auth-storage');
            localStorage.removeItem('cart-storage');
            window.location.href = '/';
        }
    };
}

// ========================================
// ALPINE.JS - CHAT WIDGET
// ========================================
function chatWidget() {
    return {
        isOpen: false,
        messages: [],
        newMessage: '',
        socket: null,

        async init() {
            // Load messages when opened
            this.$watch('isOpen', async (value) => {
                if (value && this.messages.length === 0) {
                    await this.loadMessages();
                    this.connectWebSocket();
                }
            });
        },

        async loadMessages() {
            try {
                const data = await api.get('/chat/messages');
                this.messages = data || [];
            } catch (e) {
                console.error('Failed to load messages:', e);
            }
        },

        connectWebSocket() {
            // WebSocket connection for real-time chat
            const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            const wsUrl = `${wsProtocol}//${window.location.host}/ws/chat`;

            try {
                this.socket = new WebSocket(wsUrl);
                this.socket.onmessage = (event) => {
                    const msg = JSON.parse(event.data);
                    this.messages.push(msg);
                    this.scrollToBottom();
                };
            } catch (e) {
                console.error('WebSocket connection failed:', e);
            }
        },

        async sendMessage() {
            if (!this.newMessage.trim()) return;

            try {
                await api.post('/chat/send', { content: this.newMessage });
                this.messages.push({
                    id: Date.now(),
                    content: this.newMessage,
                    isAdmin: false,
                    createdAt: new Date().toISOString()
                });
                this.newMessage = '';
                this.scrollToBottom();
            } catch (e) {
                showToast('Gagal mengirim pesan', 'error');
            }
        },

        scrollToBottom() {
            this.$nextTick(() => {
                const container = document.getElementById('chat-messages');
                if (container) {
                    container.scrollTop = container.scrollHeight;
                }
            });
        },

        formatTime(dateString) {
            return formatTime(dateString);
        }
    };
}

// ========================================
// ALPINE.JS - PRODUCT FILTER
// ========================================
function productFilter() {
    return {
        products: [],
        filteredProducts: [],
        loading: true,
        search: '',
        type: 'ALL',
        sort: 'newest',

        async init() {
            await this.loadProducts();
        },

        async loadProducts() {
            this.loading = true;
            try {
                let url = '/products?';
                if (this.type !== 'ALL') url += `type=${this.type}&`;
                if (this.sort === 'price-asc') url += 'sortBy=price&order=asc&';
                if (this.sort === 'price-desc') url += 'sortBy=price&order=desc&';
                if (this.sort === 'newest') url += 'sortBy=createdAt&order=desc&';

                const data = await api.get(url);
                this.products = data.products || data || [];
                this.filterProducts();
            } catch (e) {
                console.error('Failed to load products:', e);
            } finally {
                this.loading = false;
            }
        },

        filterProducts() {
            let result = [...this.products];

            if (this.search) {
                const searchLower = this.search.toLowerCase();
                result = result.filter(p =>
                    p.name.toLowerCase().includes(searchLower) ||
                    p.description?.toLowerCase().includes(searchLower)
                );
            }

            this.filteredProducts = result;
        },

        setType(type) {
            this.type = type;
            this.loadProducts();
        },

        setSort(sort) {
            this.sort = sort;
            this.loadProducts();
        }
    };
}

// ========================================
// ALPINE.JS - CHECKOUT
// ========================================
function checkoutState() {
    return {
        address: '',
        notes: '',
        voucherCode: '',
        voucherDiscount: 0,
        voucherError: '',
        loading: false,

        get subtotal() {
            return Alpine.store('app')?.cart?.total || 0;
        },

        get total() {
            return Math.max(0, this.subtotal - this.voucherDiscount);
        },

        async applyVoucher() {
            if (!this.voucherCode) return;

            try {
                const data = await api.post('/vouchers/apply', {
                    code: this.voucherCode,
                    subtotal: this.subtotal
                });
                this.voucherDiscount = data.discount || 0;
                this.voucherError = '';
                showToast('Voucher berhasil diterapkan!', 'success');
            } catch (e) {
                this.voucherError = e.message || 'Voucher tidak valid';
                this.voucherDiscount = 0;
            }
        },

        async processCheckout() {
            this.loading = true;
            try {
                const data = await api.post('/orders/create', {
                    address: this.address,
                    notes: this.notes,
                    voucherCode: this.voucherCode || undefined
                });

                // Initialize Midtrans Snap
                if (data.snapToken) {
                    window.snap.pay(data.snapToken, {
                        onSuccess: () => {
                            showToast('Pembayaran berhasil!', 'success');
                            Alpine.store('app').clearCart();
                            window.location.href = '/orders';
                        },
                        onPending: () => {
                            showToast('Menunggu pembayaran...', 'info');
                            window.location.href = '/orders';
                        },
                        onError: () => {
                            showToast('Pembayaran gagal', 'error');
                        },
                        onClose: () => {
                            showToast('Pembayaran dibatalkan', 'info');
                        }
                    });
                }
            } catch (e) {
                showToast(e.message || 'Checkout gagal', 'error');
            } finally {
                this.loading = false;
            }
        }
    };
}

// ========================================
// ALPINE.JS - LOGIN FORM
// ========================================
function loginForm() {
    return {
        email: '',
        password: '',
        loading: false,
        showPassword: false,

        async submit() {
            if (!this.email || !this.password) {
                showToast('Email dan password harus diisi', 'error');
                return;
            }

            this.loading = true;
            try {
                const result = await Alpine.store('app').login(this.email, this.password);

                if (result.requiresOTP) {
                    window.location.href = `/verify-otp?userId=${result.userId}`;
                } else if (result.success) {
                    window.location.href = '/';
                }
            } finally {
                this.loading = false;
            }
        }
    };
}

// ========================================
// ALPINE.JS - REGISTER FORM
// ========================================
function registerForm() {
    return {
        name: '',
        email: '',
        password: '',
        confirmPassword: '',
        loading: false,
        showPassword: false,

        async submit() {
            if (!this.name || !this.email || !this.password) {
                showToast('Semua field harus diisi', 'error');
                return;
            }

            if (this.password !== this.confirmPassword) {
                showToast('Password tidak cocok', 'error');
                return;
            }

            if (this.password.length < 6) {
                showToast('Password minimal 6 karakter', 'error');
                return;
            }

            this.loading = true;
            try {
                const result = await Alpine.store('app').register(this.name, this.email, this.password);

                if (result.success) {
                    window.location.href = `/verify-otp?userId=${result.userId}`;
                }
            } finally {
                this.loading = false;
            }
        }
    };
}

// ========================================
// REGISTER ALPINE STORES (after Alpine loads)
// ========================================
document.addEventListener('alpine:init', () => {
    // Register app state as a store for global access
    Alpine.store('app', appState());
});

// Make functions available globally
window.appState = appState;
window.adminState = adminState;
window.chatWidget = chatWidget;
window.productFilter = productFilter;
window.checkoutState = checkoutState;
window.loginForm = loginForm;
window.registerForm = registerForm;
