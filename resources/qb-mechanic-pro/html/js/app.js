/* ============================================================================
   QB-MECHANIC-PRO - Logic (Vue 2 + Mixins) - FIX FINAL DE COORDENADAS
   ============================================================================ */

/* ----------------------------------------------------------------------------
   MIXIN: UTILS
   ---------------------------------------------------------------------------- */
const MixinUtils = {
    methods: {
        async post(endpoint, data = {}) {
            const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'qb-mechanic-pro';
            try {
                const response = await fetch(`https://${resourceName}/${endpoint}`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });
                const text = await response.text();
                if (!text) return { success: true };
                try { return JSON.parse(text); } catch (e) { return { success: true }; }
            } catch (err) {
                return { success: false };
            }
        },
        formatMoney(amount) {
            return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', minimumFractionDigits: 0 }).format(amount);
        },
        // Filtro para eliminar las tiendas "fantasma" (1, 2) que mencionaste
        cleanShopList(data) {
            if (!data) return [];
            let list = Array.isArray(data) ? data : Object.values(data);
            // Solo aceptamos objetos reales con ID y nombre
            return list.filter(s => s && typeof s === 'object' && s.id && s.shop_name);
        }
    }
};

/* ----------------------------------------------------------------------------
   MIXIN: CREATOR (Aquí está la magia de ocultar/mostrar)
   ---------------------------------------------------------------------------- */
const MixinCreator = {
    data() {
        return {
            creatorView: 'manage',
            shops: [],
            isEditing: false,
            // Esta variable controla si el menú está visible o oculto
            isSelectingLocation: false, 
            shopForm: {
                id: '',
                shop_name: '',
                ownership_type: 'public',
                job_name: '',
                boss_grade: 3,
                config_data: {
                    locations: { duty: null, stash: null, bossmenu: null },
                    features: { enable_tuneshop: true, enable_carlift: true, enable_stash: true, enable_engine_swap: false },
                    blip: { sprite: 446, color: 5, scale: 0.8 }
                }
            },
            locationLabels: {
                duty: 'Servicio (Duty)',
                stash: 'Almacén',
                bossmenu: 'Menú de Jefe'
            }
        };
    },
    methods: {
        initCreateShop() {
            this.isEditing = false;
            this.shopForm = {
                id: '', shop_name: '', ownership_type: 'public', job_name: '', boss_grade: 3,
                config_data: {
                    locations: { duty: null, stash: null, bossmenu: null },
                    features: { enable_tuneshop: true, enable_carlift: true, enable_stash: true, enable_engine_swap: false },
                    blip: { sprite: 446, color: 5, scale: 0.8 }
                }
            };
            this.creatorView = 'create';
        },
        editShop(shop) {
            this.isEditing = true;
            this.shopForm = JSON.parse(JSON.stringify(shop));
            // Aseguramos que la estructura exista para evitar errores
            if(!this.shopForm.config_data) this.shopForm.config_data = {};
            if(!this.shopForm.config_data.locations) this.shopForm.config_data.locations = { duty: null, stash: null, bossmenu: null };
            if(!this.shopForm.config_data.features) this.shopForm.config_data.features = { enable_tuneshop: true, enable_carlift: true, enable_stash: true, enable_engine_swap: false };
            this.creatorView = 'create';
        },
        deleteShop(shopId) {
            if(confirm("¿Eliminar taller permanentemente?")) {
                this.post('deleteShop', { shopId }).then(() => {
                    this.post('requestShops');
                });
            }
        },
        saveShop() {
            if (!this.shopForm.id || !this.shopForm.shop_name) return;
            this.post('saveShop', this.shopForm).then(res => {
                this.post('requestShops');
                this.creatorView = 'manage';
            });
        },
        
        // --- FUNCIÓN CLAVE: INICIAR SELECCIÓN ---
        setShopLocation(type) {
            // 1. Ocultamos la UI visualmente
            this.isSelectingLocation = true; 
            
            // 2. Le decimos a Lua que empiece el modo selección
            this.post('startLocationSelection', { type });
        }
    }
};

/* ----------------------------------------------------------------------------
   MIXIN: TUNESHOP / TABLET / EXTRAS (Estándar)
   ---------------------------------------------------------------------------- */
const MixinTuneshop = {
    data() {
        return {
            currentCategory: null, showCart: false, searchQuery: '', shopId: null,
            vehicleData: { model: 'Unknown', plate: '', currentMods: {} },
            availableMods: {}, tuneCategories: [], cart: []
        };
    },
    computed: {
        cartTotal() { return this.cart.reduce((t, i) => t + i.price, 0); },
        filteredMods() {
            if (!this.currentCategory) return [];
            let mods = this.availableMods[this.currentCategory] || [];
            if (this.searchQuery) mods = mods.filter(m => m.label.toLowerCase().includes(this.searchQuery.toLowerCase()));
            return mods;
        }
    },
    methods: {
        isModInstalled(mod) { return this.vehicleData.currentMods && this.vehicleData.currentMods[mod.type] >= mod.level; },
        isInCart(mod) { return this.cart.some(i => i.id === mod.id); },
        addToCart(mod) { if (!this.isInCart(mod) && !this.isModInstalled(mod)) this.cart.push(mod); },
        removeFromCart(mod) { this.cart = this.cart.filter(i => i.id !== mod.id); },
        getModImage(mod) { return `assets/carparts/performance.png`; },
        checkout() {
            this.post('createOrder', { shopId: this.shopId, vehiclePlate: this.vehicleData.plate, vehicleModel: this.vehicleData.model, modifications: this.cart, totalCost: this.cartTotal })
            .then(res => { if(res.success) { this.closeUI(); this.cart = []; } });
        }
    }
};

const MixinTablet = {
    data() { return { tabletSection: 'dashboard', shopData: { stats: {}, orders: [], employees: [], dynoData: {} } }; },
    computed: {
        pendingOrders() { return this.shopData.orders ? this.shopData.orders.filter(o => o.status === 'pending') : []; },
        pendingOrdersCount() { return this.pendingOrders.length; },
        recentOrders() { return this.shopData.orders ? this.shopData.orders.slice(0, 5) : []; }
    },
    methods: {
        installOrder(order) { if(confirm(`¿Instalar?`)) { this.post('installOrder', { orderId: order.id, vehiclePlate: order.vehicle_plate, modifications: JSON.parse(order.modifications || '[]') }); this.closeUI(); } },
        hireEmployee() { const id = prompt("ID Jugador:"); if(id) this.post('hireEmployee', { shopId: this.shopData.id, targetServerId: id }); },
        fireEmployee(emp) { if(confirm(`¿Despedir?`)) this.post('fireEmployee', { shopId: this.shopData.id, employeeCitizenid: emp.citizenid }); }
    }
};

const MixinExtras = {
    data() { return { radialOptions: [], carliftUI: { visible: false }, installProgress: { active: false, percentage: 0 } }; },
    methods: {
        closeRadial() { this.radialOptions = []; this.post('closeRadial'); },
        handleRadialClick(opt) { this.post('radialClick', { id: opt.id, event: opt.event }); this.closeRadial(); },
        updateInstallProgress(data) {
            this.installProgress = { active: true, text: 'Instalando...', step: data.step, total: data.total, percentage: (data.step / data.total) * 100, currentMod: data.current.label };
        },
        finishInstallProgress() {
            this.installProgress.percentage = 100; this.installProgress.text = '¡Listo!'; this.installProgress.completed = true;
            setTimeout(() => { this.installProgress.active = false; }, 2500);
        }
    }
};

/* ----------------------------------------------------------------------------
   VUE APP PRINCIPAL
   ---------------------------------------------------------------------------- */
new Vue({
    el: '#app',
    mixins: [MixinUtils, MixinCreator, MixinTuneshop, MixinTablet, MixinExtras],
    data: {
        currentUI: null
    },
    methods: {
        closeUI() {
            this.currentUI = null;
            this.isSelectingLocation = false; 
            this.carliftUI.visible = false;
            this.post('closeUI');
        },
        handleMessage(event) {
            const data = event.data;
            
            // --- MANEJO DE SELECCIÓN DE COORDENADAS ---
            if (data.action === 'updateLocation') {
                // El jugador presionó E en el juego, Lua nos manda las coords
                this.isSelectingLocation = false; // Vuelve a mostrar el menú
                
                // Actualizamos el formulario
                if (this.shopForm && this.shopForm.config_data && this.shopForm.config_data.locations) {
                    // Usamos $set para asegurar que Vue actualice la vista
                    this.$set(this.shopForm.config_data.locations, data.type, data.coords);
                }
                return; 
            }

            if (data.action === 'cancelLocation') {
                // El jugador canceló con Backspace
                this.isSelectingLocation = false;
                return;
            }

            switch(data.action) {
                case 'openCreator':
                    // Filtramos los items fantasma aquí
                    this.shops = this.cleanShopList(data.shops);
                    this.currentUI = 'creator';
                    this.creatorView = 'manage';
                    break;
                
                case 'openTuneshop':
                    this.shopId = data.shopId;
                    this.vehicleData = data.vehicle || {};
                    this.availableMods = data.mods || {};
                    this.tuneCategories = data.categories || [];
                    this.currentUI = 'tuneshop';
                    break;

                case 'openTablet':
                    this.shopData = data.shop || {};
                    this.currentUI = 'tablet';
                    this.tabletSection = 'dashboard';
                    break;

                case 'openCarlift':
                    this.carliftUI.visible = true;
                    break;

                case 'updateShopData':
                    if (this.currentUI === 'creator') this.shops = this.cleanShopList(data.shops);
                    if (this.currentUI === 'tablet') this.shopData = data.shop;
                    break;

                case 'openRadial': this.radialOptions = data.options || []; break;
                case 'closeRadial': this.radialOptions = []; break;
                case 'showInstallProgress':
                case 'updateInstallProgress': this.updateInstallProgress(data); break;
                case 'hideInstallProgress': this.finishInstallProgress(); break;
                case 'closeUI': this.closeUI(); break;
            }
        }
    },
    mounted() {
        window.addEventListener('message', this.handleMessage);
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                // Si estamos seleccionando coordenadas, ESC no cierra la UI, solo cancela selección
                if (!this.isSelectingLocation) {
                    if (this.radialOptions.length > 0) this.closeRadial();
                    else if (this.carliftUI.visible) this.closeUI();
                    else if (this.currentUI) this.closeUI();
                }
            }
        });
    }
});