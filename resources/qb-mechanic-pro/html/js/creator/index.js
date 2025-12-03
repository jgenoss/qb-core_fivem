// ============================================================================
// QB-MECHANIC-PRO - Creator UI
// Sistema de creación/edición de talleres mecánicos
// Reutiliza CSS de qb-advanced-shops
// ============================================================================

window.CreatorUI = {
    shops: [],
    currentShop: null,
    editMode: false,
    currentView: 'manage', // 'manage' o 'create'

    // ------------------------------------------------------------------------
    // Inicialización
    // ------------------------------------------------------------------------
    initialize(data) {
        this.shops = data.shops || [];
        this.render();
    },

    // ------------------------------------------------------------------------
    // Renderizar UI completa
    // ------------------------------------------------------------------------
    render() {
        const container = document.getElementById('creator-ui');
        
        container.innerHTML = `
            <div id="app" style="transform: scale(1);">
                <!-- SIDEBAR -->
                <aside class="sidebar">
                    <div class="logo-container">
                        <div class="logo-icon"><i class="fas fa-store"></i></div>
                        <h4 class="logo-text">MECHANIC <span class="gradient-text">CREATOR</span></h4>
                        <div class="logo-subtitle">Professional Edition</div>
                    </div>

                    <div class="nav-menu">
                        <button class="nav-btn ${this.currentView === 'manage' ? 'active' : ''}" onclick="CreatorUI.switchView('manage')">
                            <span class="nav-icon"><i class="fas fa-list"></i></span>
                            <span class="nav-label">
                                <div class="nav-title">Gestión</div>
                                <div class="nav-desc">Administrar talleres</div>
                            </span>
                            <span class="badge-count">${this.shops.length}</span>
                        </button>

                        <button class="nav-btn ${this.currentView === 'create' ? 'active' : ''}" onclick="CreatorUI.switchView('create')">
                            <span class="nav-icon"><i class="fas fa-plus"></i></span>
                            <span class="nav-label">
                                <div class="nav-title">Crear Nuevo</div>
                                <div class="nav-desc">Configurar taller</div>
                            </span>
                            <span class="badge-new">NEW</span>
                        </button>
                    </div>

                    <div class="mt-auto settings-panel">
                        <button class="btn-close-app" onclick="MechanicUI.closeCurrentUI()">
                            <i class="fas fa-times-circle me-2"></i> Cerrar
                        </button>
                    </div>
                </aside>

                <!-- MAIN CONTENT -->
                <main class="main-content" id="main-content">
                    ${this.currentView === 'manage' ? this.renderManageView() : this.renderCreateView()}
                </main>
            </div>
        `;
    },

    // ------------------------------------------------------------------------
    // Vista de gestión de talleres
    // ------------------------------------------------------------------------
    renderManageView() {
        if (this.shops.length === 0) {
            return `
                <div class="empty-state">
                    <i class="fas fa-store-slash"></i>
                    <h3>No hay talleres creados</h3>
                    <p>Comienza creando tu primer taller mecánico</p>
                    <button class="btn-primary" onclick="CreatorUI.switchView('create')">
                        <i class="fas fa-plus"></i> Crear Taller
                    </button>
                </div>
            `;
        }

        let shopsHTML = this.shops.map(shop => `
            <div class="shop-card">
                <div class="shop-header">
                    <div class="shop-icon">
                        <i class="fas fa-wrench"></i>
                    </div>
                    <div class="shop-info">
                        <div class="shop-name">${shop.shop_name}</div>
                        <div class="shop-meta">
                            <span class="shop-type">${shop.ownership_type === 'job' ? shop.job_name : 'Public'}</span>
                            <span class="shop-items">${shop.id}</span>
                        </div>
                    </div>
                </div>
                <div class="shop-actions">
                    <button class="shop-btn shop-btn-edit" onclick="CreatorUI.editShop('${shop.id}')">
                        <i class="fas fa-edit"></i> Editar
                    </button>
                    <button class="shop-btn shop-btn-teleport" onclick="CreatorUI.teleportToShop('${shop.id}')">
                        <i class="fas fa-map-marker-alt"></i> Teleport
                    </button>
                    <button class="shop-btn shop-btn-delete" onclick="CreatorUI.confirmDelete('${shop.id}')">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
        `).join('');

        return `
            <header class="header-bar">
                <div class="header-content">
                    <h5 class="header-title">Talleres Mecánicos</h5>
                    <span class="header-subtitle">Gestión de talleres activos</span>
                </div>
            </header>
            <div class="content-grid">
                ${shopsHTML}
            </div>
        `;
    },

    // ------------------------------------------------------------------------
    // Vista de creación/edición
    // ------------------------------------------------------------------------
    renderCreateView() {
        const shop = this.currentShop || {
            id: '',
            shop_name: '',
            ownership_type: 'public',
            job_name: '',
            minimum_grade: 0,
            boss_grade: 3,
            config_data: {
                blip: {
                    enabled: true,
                    sprite: 446,
                    color: 5,
                    scale: 0.8,
                    label: ''
                },
                locations: {
                    duty: null,
                    stash: null,
                    bossmenu: null,
                    tuneshop: [],
                    carlift: []
                },
                features: {
                    enable_tuneshop: true,
                    enable_carlift: true,
                    enable_stash: true,
                    enable_engine_swap: false
                }
            }
        };

        return `
            <header class="header-bar">
                <div class="header-content">
                    <h5 class="header-title">${this.editMode ? 'Editar' : 'Crear'} Taller</h5>
                    <span class="header-subtitle">Configuración completa</span>
                </div>
            </header>

            <div class="form-container">
                <!-- INFORMACIÓN BÁSICA -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="fas fa-info-circle"></i> Información Básica
                    </h3>
                    
                    <div class="form-group">
                        <label>ID del Taller</label>
                        <input type="text" id="shop-id" class="form-input" 
                               placeholder="bennys_lsia" value="${shop.id}" 
                               ${this.editMode ? 'disabled' : ''}>
                    </div>

                    <div class="form-group">
                        <label>Nombre del Taller</label>
                        <input type="text" id="shop-name" class="form-input" 
                               placeholder="Benny's Original Motor Works" value="${shop.shop_name}">
                    </div>

                    <div class="form-group">
                        <label>Tipo de Propiedad</label>
                        <select id="ownership-type" class="form-input" onchange="CreatorUI.toggleJobFields()">
                            <option value="public" ${shop.ownership_type === 'public' ? 'selected' : ''}>Público</option>
                            <option value="job" ${shop.ownership_type === 'job' ? 'selected' : ''}>Restringido por Trabajo</option>
                        </select>
                    </div>

                    <div class="form-group" id="job-fields" style="display: ${shop.ownership_type === 'job' ? 'block' : 'none'};">
                        <label>Nombre del Trabajo</label>
                        <input type="text" id="job-name" class="form-input" 
                               placeholder="mechanic" value="${shop.job_name || ''}">
                        
                        <div class="form-row">
                            <div class="form-col">
                                <label>Grado Mínimo</label>
                                <input type="number" id="minimum-grade" class="form-input" 
                                       min="0" max="10" value="${shop.minimum_grade}">
                            </div>
                            <div class="form-col">
                                <label>Grado de Jefe</label>
                                <input type="number" id="boss-grade" class="form-input" 
                                       min="0" max="10" value="${shop.boss_grade}">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- UBICACIONES -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="fas fa-map-marker-alt"></i> Ubicaciones
                    </h3>
                    
                    <div class="location-list">
                        ${this.renderLocationField('duty', 'Servicio', shop)}
                        ${this.renderLocationField('stash', 'Almacén', shop)}
                        ${this.renderLocationField('bossmenu', 'Menú Jefe', shop)}
                    </div>
                </div>

                <!-- CARACTERÍSTICAS -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="fas fa-cog"></i> Características
                    </h3>
                    
                    <div class="features-grid">
                        ${this.renderFeatureToggle('enable_tuneshop', 'Taller de Tuning', shop)}
                        ${this.renderFeatureToggle('enable_carlift', 'Elevador', shop)}
                        ${this.renderFeatureToggle('enable_stash', 'Almacén', shop)}
                        ${this.renderFeatureToggle('enable_engine_swap', 'Intercambio de Motor', shop)}
                    </div>
                </div>

                <!-- BLIP -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="fas fa-map"></i> Configuración de Blip
                    </h3>
                    
                    <div class="form-row">
                        <div class="form-col">
                            <label>Sprite</label>
                            <input type="number" id="blip-sprite" class="form-input" 
                                   value="${shop.config_data.blip.sprite}">
                        </div>
                        <div class="form-col">
                            <label>Color</label>
                            <input type="number" id="blip-color" class="form-input" 
                                   value="${shop.config_data.blip.color}">
                        </div>
                        <div class="form-col">
                            <label>Escala</label>
                            <input type="number" id="blip-scale" class="form-input" 
                                   step="0.1" min="0.5" max="2.0" value="${shop.config_data.blip.scale}">
                        </div>
                    </div>
                </div>

                <!-- BOTONES DE ACCIÓN -->
                <div class="form-actions">
                    <button class="btn-secondary" onclick="CreatorUI.switchView('manage')">
                        <i class="fas fa-times"></i> Cancelar
                    </button>
                    <button class="btn-primary" onclick="CreatorUI.saveShop()">
                        <i class="fas fa-save"></i> ${this.editMode ? 'Actualizar' : 'Crear'} Taller
                    </button>
                </div>
            </div>
        `;
    },

    // ------------------------------------------------------------------------
    // Renderizar campo de ubicación
    // ------------------------------------------------------------------------
    renderLocationField(type, label, shop) {
        const location = shop.config_data.locations[type];
        const hasLocation = location && location.x !== undefined;

        return `
            <div class="location-item">
                <div class="location-info">
                    <i class="fas fa-map-pin"></i>
                    <span>${label}</span>
                    ${hasLocation ? `<span class="location-coords">${location.x.toFixed(2)}, ${location.y.toFixed(2)}</span>` : ''}
                </div>
                <div class="location-actions">
                    <button class="btn-sm btn-primary" onclick="CreatorUI.setLocation('${type}')">
                        <i class="fas fa-crosshairs"></i> ${hasLocation ? 'Cambiar' : 'Establecer'}
                    </button>
                    ${hasLocation ? `<button class="btn-sm btn-danger" onclick="CreatorUI.removeLocation('${type}')">
                        <i class="fas fa-trash"></i>
                    </button>` : ''}
                </div>
            </div>
        `;
    },

    // ------------------------------------------------------------------------
    // Renderizar toggle de característica
    // ------------------------------------------------------------------------
    renderFeatureToggle(feature, label, shop) {
        const enabled = shop.config_data.features[feature];
        
        return `
            <div class="feature-toggle">
                <label class="switch">
                    <input type="checkbox" id="${feature}" ${enabled ? 'checked' : ''}>
                    <span class="slider"></span>
                </label>
                <span>${label}</span>
            </div>
        `;
    },

    // ------------------------------------------------------------------------
    // Funciones de interacción
    // ------------------------------------------------------------------------
    switchView(view) {
        this.currentView = view;
        if (view === 'manage') {
            this.currentShop = null;
            this.editMode = false;
        }
        this.render();
    },

    toggleJobFields() {
        const ownershipType = document.getElementById('ownership-type').value;
        const jobFields = document.getElementById('job-fields');
        jobFields.style.display = ownershipType === 'job' ? 'block' : 'none';
    },

    editShop(shopId) {
        this.currentShop = this.shops.find(s => s.id === shopId);
        this.editMode = true;
        this.switchView('create');
    },

    setLocation(type) {
        MechanicUI.post('setLocation', { type }).then(() => {
            // La ubicación se actualizará via callback desde Lua
        });
    },

    removeLocation(type) {
        if (this.currentShop && this.currentShop.config_data.locations[type]) {
            this.currentShop.config_data.locations[type] = null;
            this.render();
        }
    },

    teleportToShop(shopId) {
        MechanicUI.post('teleportToShop', { shopId });
    },

    confirmDelete(shopId) {
        if (confirm('¿Estás seguro de que quieres eliminar este taller? Esta acción no se puede deshacer.')) {
            MechanicUI.post('deleteShop', { shopId }).then(() => {
                this.shops = this.shops.filter(s => s.id !== shopId);
                this.render();
            });
        }
    },

    saveShop() {
        const shopData = this.collectFormData();
        
        if (!this.validateShopData(shopData)) {
            return;
        }

        MechanicUI.post('saveShop', shopData).then(response => {
            if (response.success) {
                this.switchView('manage');
                // Recargar shops
                MechanicUI.post('requestShops', {});
            }
        });
    },

    collectFormData() {
        const ownershipType = document.getElementById('ownership-type').value;
        
        return {
            id: document.getElementById('shop-id').value,
            shop_name: document.getElementById('shop-name').value,
            ownership_type: ownershipType,
            job_name: ownershipType === 'job' ? document.getElementById('job-name').value : null,
            minimum_grade: parseInt(document.getElementById('minimum-grade').value) || 0,
            boss_grade: parseInt(document.getElementById('boss-grade').value) || 3,
            config_data: this.currentShop ? this.currentShop.config_data : {
                blip: {
                    enabled: true,
                    sprite: parseInt(document.getElementById('blip-sprite').value) || 446,
                    color: parseInt(document.getElementById('blip-color').value) || 5,
                    scale: parseFloat(document.getElementById('blip-scale').value) || 0.8,
                    label: document.getElementById('shop-name').value
                },
                locations: this.currentShop ? this.currentShop.config_data.locations : {},
                features: {
                    enable_tuneshop: document.getElementById('enable_tuneshop')?.checked || false,
                    enable_carlift: document.getElementById('enable_carlift')?.checked || false,
                    enable_stash: document.getElementById('enable_stash')?.checked || false,
                    enable_engine_swap: document.getElementById('enable_engine_swap')?.checked || false
                }
            }
        };
    },

    validateShopData(data) {
        if (!data.id || data.id.trim() === '') {
            alert('El ID del taller es obligatorio');
            return false;
        }
        
        if (!data.shop_name || data.shop_name.trim() === '') {
            alert('El nombre del taller es obligatorio');
            return false;
        }
        
        if (data.ownership_type === 'job' && (!data.job_name || data.job_name.trim() === '')) {
            alert('El nombre del trabajo es obligatorio para talleres restringidos');
            return false;
        }
        
        return true;
    },

    cleanup() {
        this.currentShop = null;
        this.editMode = false;
    }
};