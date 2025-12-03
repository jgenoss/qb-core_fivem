// ============================================================================
// QB-MECHANIC-PRO - Tuneshop UI
// Tienda de tuning para clientes
// Reutiliza CSS de qb-shop-ui (market-layout, grid 6 productos)
// ============================================================================

window.TuneshopUI = {
    shopId: null,
    vehicle: null,
    categories: [],
    mods: {},
    cart: [],
    currentCategory: null,
    searchTerm: '',

    // ------------------------------------------------------------------------
    // Inicialización
    // ------------------------------------------------------------------------
    initialize(data) {
        this.shopId = data.shopId;
        this.vehicle = data.vehicle;
        this.categories = data.categories;
        this.mods = data.mods;
        this.cart = [];
        
        this.render();
        this.loadCategory(this.categories[0].id);
    },

    // ------------------------------------------------------------------------
    // Renderizar UI completa
    // ------------------------------------------------------------------------
    render() {
        const container = document.getElementById('tuneshop-ui');
        
        container.innerHTML = `
            <div class="market-layout">
                <!-- SIDEBAR -->
                <aside class="market-sidebar">
                    <div class="market-logo">
                        <i class="fas fa-wrench"></i> TUNING SHOP
                    </div>

                    <div class="category-list">
                        ${this.renderCategories()}
                    </div>

                    <div class="mt-auto">
                        <button class="btn btn-dark w-100" onclick="MechanicUI.closeCurrentUI()">
                            <i class="fas fa-times"></i> Cerrar
                        </button>
                    </div>
                </aside>

                <!-- MAIN CONTENT -->
                <div class="market-main">
                    <!-- Header -->
                    <header class="market-header">
                        <div>
                            <h2>${this.vehicle.model}</h2>
                            <small>Placa: ${this.vehicle.plate}</small>
                        </div>
                        <div class="search-bar">
                            <i class="fas fa-search"></i>
                            <input type="text" placeholder="Buscar modificaciones..." 
                                   oninput="TuneshopUI.handleSearch(event)">
                        </div>
                    </header>

                    <!-- Grid de productos -->
                    <div class="market-grid-container" id="products-grid">
                        ${this.renderProducts()}
                    </div>
                </div>

                <!-- CART PANEL -->
                <aside class="cart-panel">
                    <h3 class="cart-title">
                        <i class="fas fa-shopping-cart"></i> Carrito
                    </h3>
                    
                    <div class="cart-items" id="cart-items">
                        ${this.renderCart()}
                    </div>

                    <div class="cart-footer">
                        <div class="cart-total">
                            <span>Total:</span>
                            <span class="cart-total-amount">${this.formatMoney(this.getCartTotal())}</span>
                        </div>
                        <button class="btn-checkout" onclick="TuneshopUI.checkout()" 
                                ${this.cart.length === 0 ? 'disabled' : ''}>
                            <i class="fas fa-check"></i> Realizar Pedido
                        </button>
                        <button class="btn-clear-cart" onclick="TuneshopUI.clearCart()">
                            <i class="fas fa-trash"></i> Vaciar Carrito
                        </button>
                    </div>
                </aside>
            </div>
        `;
    },

    // ------------------------------------------------------------------------
    // Renderizar categorías
    // ------------------------------------------------------------------------
    renderCategories() {
        return this.categories.map(cat => `
            <button class="category-btn ${this.currentCategory === cat.id ? 'active' : ''}" 
                    onclick="TuneshopUI.loadCategory('${cat.id}')">
                <i class="${cat.icon}"></i>
                ${cat.label}
            </button>
        `).join('');
    },

    // ------------------------------------------------------------------------
    // Renderizar productos
    // ------------------------------------------------------------------------
    renderProducts() {
        if (!this.currentCategory) {
            return '<div class="empty-state">Selecciona una categoría</div>';
        }

        const products = this.getProductsForCategory();
        
        if (products.length === 0) {
            return '<div class="empty-state">No hay modificaciones disponibles</div>';
        }

        return products.map(product => this.renderProductCard(product)).join('');
    },

    // ------------------------------------------------------------------------
    // Renderizar tarjeta de producto
    // ------------------------------------------------------------------------
    renderProductCard(product) {
        const isInstalled = this.isModInstalled(product);
        const inCart = this.isInCart(product);
        
        return `
            <div class="product-card-modern">
                <div class="price-tag">${this.formatMoney(product.price)}</div>
                
                <div class="prod-img">
                    <i class="fas ${this.getModIcon(product.type)} fa-3x"></i>
                </div>
                
                <div class="prod-info">
                    <h5 class="prod-name">${product.label}</h5>
                    ${product.maxLevel ? `<div class="prod-level">Nivel ${product.maxLevel}</div>` : ''}
                </div>

                ${isInstalled ? `
                    <div class="badge-installed">
                        <i class="fas fa-check"></i> Instalado
                    </div>
                ` : inCart ? `
                    <button class="btn-add-to-cart" onclick="TuneshopUI.removeFromCart('${product.id}')" disabled>
                        <i class="fas fa-check"></i> En Carrito
                    </button>
                ` : `
                    <button class="btn-add-to-cart" onclick="TuneshopUI.addToCart(${JSON.stringify(product).replace(/"/g, '&quot;')})">
                        <i class="fas fa-plus"></i> Agregar
                    </button>
                `}
            </div>
        `;
    },

    // ------------------------------------------------------------------------
    // Renderizar carrito
    // ------------------------------------------------------------------------
    renderCart() {
        if (this.cart.length === 0) {
            return '<div class="cart-empty">Carrito vacío</div>';
        }

        return this.cart.map((item, index) => `
            <div class="cart-item">
                <div class="cart-item-info">
                    <i class="fas ${this.getModIcon(item.type)}"></i>
                    <div>
                        <div class="cart-item-name">${item.label}</div>
                        <div class="cart-item-price">${this.formatMoney(item.price)}</div>
                    </div>
                </div>
                <button class="btn-remove-item" onclick="TuneshopUI.removeFromCart('${item.id}')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        `).join('');
    },

    // ------------------------------------------------------------------------
    // Gestión de categorías
    // ------------------------------------------------------------------------
    loadCategory(categoryId) {
        this.currentCategory = categoryId;
        
        // Actualizar UI
        const productsGrid = document.getElementById('products-grid');
        if (productsGrid) {
            productsGrid.innerHTML = this.renderProducts();
        }
        
        // Actualizar botones de categoría
        document.querySelectorAll('.category-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        event.target.closest('.category-btn')?.classList.add('active');
    },

    getProductsForCategory() {
        if (this.currentCategory === 'performance') {
            return this.mods.performance || [];
        } else if (this.currentCategory === 'cosmetic') {
            return this.mods.cosmetic || [];
        }
        return [];
    },

    // ------------------------------------------------------------------------
    // Gestión del carrito
    // ------------------------------------------------------------------------
    addToCart(product) {
        // Evitar duplicados
        if (this.isInCart(product)) {
            return;
        }

        this.cart.push(product);
        this.updateCart();
    },

    removeFromCart(productId) {
        this.cart = this.cart.filter(item => item.id !== productId);
        this.updateCart();
    },

    clearCart() {
        if (confirm('¿Vaciar el carrito?')) {
            this.cart = [];
            this.updateCart();
        }
    },

    isInCart(product) {
        return this.cart.some(item => item.id === product.id);
    },

    getCartTotal() {
        return this.cart.reduce((total, item) => total + item.price, 0);
    },

    updateCart() {
        const cartContainer = document.getElementById('cart-items');
        if (cartContainer) {
            cartContainer.innerHTML = this.renderCart();
        }

        // Actualizar total
        const totalElement = document.querySelector('.cart-total-amount');
        if (totalElement) {
            totalElement.textContent = this.formatMoney(this.getCartTotal());
        }

        // Actualizar botón de checkout
        const checkoutBtn = document.querySelector('.btn-checkout');
        if (checkoutBtn) {
            checkoutBtn.disabled = this.cart.length === 0;
        }

        // Re-renderizar productos para actualizar estados
        const productsGrid = document.getElementById('products-grid');
        if (productsGrid) {
            productsGrid.innerHTML = this.renderProducts();
        }
    },

    // ------------------------------------------------------------------------
    // Checkout
    // ------------------------------------------------------------------------
    checkout() {
        if (this.cart.length === 0) {
            return;
        }

        const orderData = {
            shopId: this.shopId,
            vehiclePlate: this.vehicle.plate,
            vehicleModel: this.vehicle.model,
            modifications: this.cart.map(item => ({
                type: item.type,
                id: item.id,
                label: item.label,
                price: item.price,
                level: item.maxLevel || 0,
                modIndex: item.modIndex
            })),
            totalCost: this.getCartTotal()
        };

        MechanicUI.post('createOrder', orderData).then(response => {
            if (response.success) {
                MechanicUI.showNotification('Orden creada exitosamente', 'success');
                this.cart = [];
                MechanicUI.closeCurrentUI();
            } else {
                MechanicUI.showNotification(response.message || 'Error al crear orden', 'error');
            }
        });
    },

    // ------------------------------------------------------------------------
    // Búsqueda
    // ------------------------------------------------------------------------
    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
        
        const productsGrid = document.getElementById('products-grid');
        if (productsGrid) {
            productsGrid.innerHTML = this.renderProducts();
        }
    },

    // ------------------------------------------------------------------------
    // Utilidades
    // ------------------------------------------------------------------------
    isModInstalled(product) {
        if (!this.vehicle.currentMods) return false;
        
        // Verificar si el mod está instalado
        if (product.type === 'engine') {
            return this.vehicle.currentMods.modEngine >= 0;
        } else if (product.type === 'brakes') {
            return this.vehicle.currentMods.modBrakes >= 0;
        } else if (product.type === 'turbo') {
            return this.vehicle.currentMods.modTurbo;
        }
        
        return false;
    },

    getModIcon(type) {
        const icons = {
            'engine': 'fa-cog',
            'brakes': 'fa-stop',
            'transmission': 'fa-gears',
            'suspension': 'fa-up-down',
            'turbo': 'fa-wind',
            'spoiler': 'fa-car-side',
            'fbumper': 'fa-car-front',
            'rbumper': 'fa-car-rear',
            'exhaust': 'fa-cloud'
        };
        
        return icons[type] || 'fa-wrench';
    },

    formatMoney(amount) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0
        }).format(amount);
    },

    cleanup() {
        this.cart = [];
        this.currentCategory = null;
    }
};