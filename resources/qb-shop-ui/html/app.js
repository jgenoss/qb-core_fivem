// 🔥 IMPORTANTE: Cambiar esto por el nombre EXACTO de tu carpeta
const resourceName = 'qb-shop-ui';

new Vue({
    el: '#shop-app',
    data: {
        show: false,
        shopData: {
            id: null,
            name: 'Cargando...',
            type: 'general',
            items: []
        },
        categories: [],
        imgDir: '',
        
        // UI State
        selectedCategory: 'all',
        search: '',
        cart: [],
        isProcessing: false
    },
    
    computed: {
        filteredItems() {
            let items = this.shopData.items;
            
            // Filtrar por categoría
            if (this.selectedCategory !== 'all') {
                items = items.filter(i => i.category === this.selectedCategory);
            }
            
            // Filtrar por búsqueda
            if (this.search.trim()) {
                const q = this.search.toLowerCase();
                items = items.filter(i => 
                    i.label.toLowerCase().includes(q) || 
                    i.name.toLowerCase().includes(q)
                );
            }
            
            return items;
        },
        
        cartTotalItems() {
            return this.cart.reduce((sum, item) => sum + item.qty, 0);
        },
        
        cartTotalPrice() {
            return this.cart.reduce((sum, item) => sum + (item.price * item.qty), 0);
        },
        
        availableCategories() {
            return this.categories;
        }
    },
    
    methods: {
        // ============================================
        // GESTIÓN DEL CARRITO
        // ============================================
        addToCart(item) {
            const existing = this.cart.find(i => i.name === item.name);
            
            if (existing) {
                // Verificar stock disponible
                if (item.amount !== -1 && existing.qty >= item.amount) {
                    console.warn('Stock máximo alcanzado');
                    return;
                }
                existing.qty++;
            } else {
                this.cart.push({
                    name: item.name,
                    label: item.label,
                    price: item.price,
                    image: item.image,
                    qty: 1,
                    maxAmount: item.amount
                });
            }
        },
        
        updateQty(index, delta) {
            const item = this.cart[index];
            const newQty = item.qty + delta;
            
            if (newQty <= 0) {
                this.removeFromCart(index);
                return;
            }
            
            // Verificar stock
            if (item.maxAmount !== -1 && newQty > item.maxAmount) {
                console.warn('Stock insuficiente');
                return;
            }
            
            item.qty = newQty;
        },
        
        removeFromCart(index) {
            this.cart.splice(index, 1);
        },
        
        // ============================================
        // PROCESAMIENTO DE COMPRA
        // ============================================
        async checkout(paymentMethod) {
            if (this.cart.length === 0) return;
            if (this.isProcessing) return;
            
            this.isProcessing = true;
            
            try {
                const response = await axios.post(`https://${resourceName}/processPurchase`, {
                    cart: this.cart,
                    paymentMethod: paymentMethod,
                    total: this.cartTotalPrice
                });
                
                if (response.data.success) {
                    this.cart = [];
                    
                    // Cerrar automáticamente tras 1 segundo
                    setTimeout(() => {
                        this.closeShop();
                    }, 1000);
                } else {
                    console.error('Error en compra:', response.data.message);
                }
            } catch (error) {
                console.error('Error en checkout:', error);
            } finally {
                this.isProcessing = false;
            }
        },
        
        // ============================================
        // UI HELPERS
        // ============================================
        closeShop() {
            this.show = false;
            this.cart = [];
            this.search = '';
            this.selectedCategory = 'all';
            
            axios.post(`https://${resourceName}/closeShop`).catch(() => {});
        },
        
        handleImgErr(e) {
            e.target.style.display = 'none';
        }
    },
    
    mounted() {
        
        // Listener principal
        window.addEventListener('message', (event) => {
            const data = event.data;

            if (data.action === 'openShop') {

                
                this.shopData = data.shopData;
                this.categories = data.categories || [];
                this.imgDir = data.imgDir;
                this.show = true;
                this.cart = [];
                this.search = '';
                this.selectedCategory = 'all';
            }
        });
        
        // ESC para cerrar
        window.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.show) {
                this.closeShop();
            }
        });
    }
});