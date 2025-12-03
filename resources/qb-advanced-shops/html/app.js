const resourceName = 'qb-advanced-shops';

new Vue({
    el: '#app',
    data: {
        show: false,
        view: 'manage',
        step: 1,

        // UI
        ui: { scale: 1.0, top: 100, left: 100 },
        isDragging: false,
        dragOffset: { x: 0, y: 0 },

        // Data
        shops: [],
        items: [],
        imgDir: '',

        // Config loaded from Lua
        shopTypes: [],
        pedModels: [],
        itemCategories: [],
        blipPresets: [],

        // Forms & Search
        itemSearch: '',
        pedSearch: '',
        form: {
            name: '',
            type: 'general',
            pedModel: 'mp_m_shopkeep_01',
            blip: { enable: true, sprite: 52, color: 2 },
            items: []
        },
        isEditMode: false,  // NUEVO
        editingShopId: null, // NUEVO
    },
    computed: {
        containerStyle() {
            return {
                transform: `scale(${this.ui.scale})`,
                top: this.ui.top + 'px',
                left: this.ui.left + 'px'
            }
        },
        canNext() {
            if (this.step === 1) return this.form.name && this.form.type;
            if (this.step === 3) return this.form.items.length > 0;
            return true;
        },
        filteredPeds() {
            const q = this.pedSearch.toLowerCase();
            if (!q) return this.pedModels;
            return this.pedModels.map(cat => ({
                category: cat.category,
                peds: cat.peds.filter(p => p.label.toLowerCase().includes(q) || p.model.toLowerCase().includes(q))
            })).filter(c => c.peds.length > 0);
        }
    },
    methods: {
        // --- DRAG ---
        startDrag(e) {
            if (e.button !== 0) return;
            this.isDragging = true;
            this.dragOffset.x = e.clientX - this.ui.left;
            this.dragOffset.y = e.clientY - this.ui.top;
            window.addEventListener('mousemove', this.onDrag);
            window.addEventListener('mouseup', this.stopDrag);
        },
        onDrag(e) {
            if (!this.isDragging) return;
            this.ui.left = e.clientX - this.dragOffset.x;
            this.ui.top = e.clientY - this.dragOffset.y;
        },
        stopDrag() {
            this.isDragging = false;
            window.removeEventListener('mousemove', this.onDrag);
            window.removeEventListener('mouseup', this.stopDrag);
            this.saveSettings();
        },
        bringToFront() { },
        saveSettings() {
            localStorage.setItem('shopcreator_ui', JSON.stringify(this.ui));
        },

        // --- LOGIC ---
        resetCreator() {
            this.view = 'create';
            this.step = 1;
            this.isEditMode = false;      // NUEVO
            this.editingShopId = null;     // NUEVO
            this.form = {
                name: '',
                type: 'general',
                pedModel: 'mp_m_shopkeep_01',
                blip: { enable: true, sprite: 52, color: 2 },
                items: []
            };
            this.req('removePreviewPed');
            this.req('removePreviewBlip');
        },

        selectPed(model) {
            this.form.pedModel = model;
            this.req('previewPed', { model });
        },

        getPedLabel(model) {
            for (let cat of this.pedModels) {
                let p = cat.peds.find(x => x.model === model);
                if (p) return p.label;
            }
            return model;
        },

        // Items Logic
        getCategoryItems(catId) {
            const q = this.itemSearch.toLowerCase();
            let items = [];

            if (catId === 'misc') {
                items = this.items.filter(i => {
                    return !this.itemCategories.some(c => c.id !== 'misc' && c.keywords.some(k => i.name.includes(k)));
                });
            } else {
                const cat = this.itemCategories.find(c => c.id === catId);
                if (!cat) return [];
                items = this.items.filter(i => cat.keywords.some(k => i.name.includes(k)));
            }

            if (q) {
                items = items.filter(i => i.label.toLowerCase().includes(q) || i.name.toLowerCase().includes(q));
            }
            return items;
        },

        isSelected(name) {
            return this.form.items.find(i => i.name === name);
        },

        getItem(name) {
            return this.form.items.find(i => i.name === name);
        },

        toggleItem(item) {
            const idx = this.form.items.findIndex(i => i.name === item.name);
            if (idx > -1) this.form.items.splice(idx, 1);
            else this.form.items.push({ name: item.name, price: 10, amount: 100 });
        },

        // Blips
        selectBlip(preset) {
            this.form.blip.sprite = preset.sprite;
            this.form.blip.color = preset.color;
            this.previewBlip();
        },

        previewBlip() {
            if (this.form.blip.enable) this.req('previewBlip', this.form.blip);
            else this.req('removePreviewBlip');
        },

        // API
        getTypeLabel(val) {
            return this.shopTypes.find(t => t.value === val)?.label || val;
        },

        handleImgErr(e) {
            e.target.style.display = 'none';
        },

        finish() {
            this.req('startPlacement', this.form);
            this.show = false;
        },

        teleport(shop) {
            this.req('teleportToShop', { coords: shop.coords });
        },

        async deleteShop(shop) {
            try {
                // 🔥 AXIOS: Enviar ID limpio como número
                await axios.post(`https://${resourceName}/deleteShop`, {
                    id: parseInt(shop.id)
                });

                // Remover del array local
                this.shops = this.shops.filter(s => s.id !== shop.id);

                console.log(`✅ Tienda #${shop.id} eliminada correctamente`);
            } catch (error) {
                console.error('❌ Error al eliminar tienda:', error);
            }
        },

        closeUI() {
            this.show = false;
            this.req('close');
        },
        async editShop(shop) {
            try {
                await this.req('editShop', { id: shop.id });
                // El callback se maneja en mounted() con el listener 'loadShopForEdit'
            } catch (error) {
                console.error('Error al cargar tienda para editar:', error);
            }
        },

        // 💾 FINALIZAR EDICIÓN
        finishEdit() {
            if (this.isEditMode) {
                this.req('updatePlacement', this.form);
            } else {
                this.req('startPlacement', this.form);
            }
            this.show = false;
        },

        // 🔄 ACTUALIZAR TIENDA (LLAMADO DESDE STEP 4)
        updateShop() {
            const updateData = {
                id: this.editingShopId,
                name: this.form.name,
                type: this.form.type,
                pedModel: this.form.pedModel,
                coords: this.form.coords,
                items: this.form.items,
                blip: this.form.blip
            };

            this.req('updateShop', updateData);
            this.show = false;
            this.isEditMode = false;
            this.editingShopId = null;
        },
        // 🔥 NUEVA FUNCIÓN CON AXIOS
        async req(endpoint, data = {}) {
            try {
                const response = await axios.post(`https://${resourceName}/${endpoint}`, data);
                return response.data;
            } catch (error) {
                console.error(`❌ Error en ${endpoint}:`, error);
                return null;
            }
        }
    },

    mounted() {
        // Cargar configuración guardada
        const saved = localStorage.getItem('shopcreator_ui');
        if (saved) this.ui = JSON.parse(saved);

        // Listener para abrir dashboard
        window.addEventListener('message', (event) => {
            if (event.data.action === 'openDashboard') {
                this.items = event.data.items || [];
                this.shops = event.data.shops || [];
                this.imgDir = event.data.imgDir;
                this.shopTypes = event.data.shopTypes;
                this.pedModels = event.data.pedModels;
                this.itemCategories = event.data.itemCategories;
                this.blipPresets = event.data.blipPresets || [];

                this.show = true;
                this.view = 'manage';
            }
            if (event.data.action === 'loadShopForEdit') {
                const shop = event.data.shop;

                // Pre-llenar formulario con datos de la tienda
                this.form = {
                    name: shop.name,
                    type: shop.type,
                    pedModel: shop.pedModel,
                    coords: shop.coords,
                    items: shop.items.map(item => ({
                        name: item.name,
                        price: item.price || 10,
                        amount: item.amount || 100
                    })),
                    blip: shop.blip || { enable: true, sprite: 52, color: 2 }
                };

                // Configurar modo edición
                this.isEditMode = true;
                this.editingShopId = shop.id;
                this.view = 'create';
                this.step = 1;

                console.log(`📝 Tienda #${shop.id} cargada para edición`);
            }
        });

        // ESC para cerrar
        window.addEventListener('keydown', e => {
            if (e.key === 'Escape') this.closeUI();
        });
    }
});