// ============================================================================
// QB-MECHANIC-PRO - Main UI Controller (Refactorizado)
// Solo coordinación y enrutamiento - La lógica está en módulos separados
// ============================================================================

const MechanicUI = {
    currentUI: null,

    // ------------------------------------------------------------------------
    // Inicialización
    // ------------------------------------------------------------------------
    init() {
        this.setupEventListeners();
        Utils.log('UI System initialized', 'success');
    },

    // ------------------------------------------------------------------------
    // Setup de event listeners
    // ------------------------------------------------------------------------
    setupEventListeners() {
        // Escuchar mensajes desde Lua
        window.addEventListener('message', (event) => {
            this.handleMessage(event.data);
        });

        // Cerrar UI con ESC
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.currentUI) {
                this.closeCurrentUI();
            }
        });
    },

    // ------------------------------------------------------------------------
    // Router de mensajes
    // ------------------------------------------------------------------------
    handleMessage(data) {
        const action = data.action;
        
        // UIs principales
        if (action === 'openCreator') {
            this.openUI('creator', data);
            return;
        }
        
        if (action === 'openTuneshop') {
            this.openUI('tuneshop', data);
            return;
        }
        
        if (action === 'openTablet') {
            this.openUI('tablet', data);
            return;
        }
        
        // Sistema de progreso de instalación
        if (action === 'showInstallProgress') {
            InstallProgress.show(data);
            return;
        }
        
        if (action === 'updateInstallProgress') {
            InstallProgress.update(data);
            return;
        }
        
        if (action === 'hideInstallProgress') {
            InstallProgress.hide();
            return;
        }
        
        // Radial menu
        if (action === 'openRadial') {
            this.openRadialMenu(data.options);
            return;
        }
        
        if (action === 'closeRadial') {
            this.closeRadialMenu();
            return;
        }
        
        // Cierre de UIs
        if (action === 'closeUI') {
            this.closeCurrentUI();
            return;
        }
        
        if (action === 'closeAll') {
            this.closeAllUIs();
            return;
        }
        
        // Si llegamos aquí, intentar delegar a UIs específicas
        this.delegateToUI(action, data);
    },

    // ------------------------------------------------------------------------
    // Delegar mensaje a UI específica
    // ------------------------------------------------------------------------
    delegateToUI(action, data) {
        // TabletUI
        if (window.TabletUI && typeof window.TabletUI[action] === 'function') {
            window.TabletUI[action](data);
            return;
        }
        
        // TuneshopUI
        if (window.TuneshopUI && typeof window.TuneshopUI[action] === 'function') {
            window.TuneshopUI[action](data);
            return;
        }
        
        // CreatorUI
        if (window.CreatorUI && typeof window.CreatorUI[action] === 'function') {
            window.CreatorUI[action](data);
            return;
        }
        
        Utils.log(`Unhandled action: ${action}`, 'warning');
    },

    // ------------------------------------------------------------------------
    // Abrir UI específica
    // ------------------------------------------------------------------------
    openUI(uiName, data) {
        // Cerrar UI actual si hay alguna
        if (this.currentUI) {
            this.closeCurrentUI();
        }

        const uiElement = document.getElementById(`${uiName}-ui`);
        if (!uiElement) {
            Utils.log(`UI "${uiName}" not found`, 'error');
            return;
        }

        // Mostrar UI
        uiElement.classList.add('active');
        this.currentUI = uiName;

        // Inicializar UI específica
        this.initializeUI(uiName, data);
        
        Utils.log(`Opened ${uiName} UI`, 'info');
    },

    // ------------------------------------------------------------------------
    // Inicializar UI específica
    // ------------------------------------------------------------------------
    initializeUI(uiName, data) {
        switch (uiName) {
            case 'creator':
                if (window.CreatorUI && window.CreatorUI.initialize) {
                    window.CreatorUI.initialize(data);
                }
                break;

            case 'tuneshop':
                if (window.TuneshopUI && window.TuneshopUI.initialize) {
                    window.TuneshopUI.initialize(data);
                }
                break;

            case 'tablet':
                if (window.TabletUI && window.TabletUI.initialize) {
                    window.TabletUI.initialize(data);
                }
                break;
        }
    },

    // ------------------------------------------------------------------------
    // Cleanup UI específica
    // ------------------------------------------------------------------------
    cleanupUI(uiName) {
        switch (uiName) {
            case 'creator':
                if (window.CreatorUI && window.CreatorUI.cleanup) {
                    window.CreatorUI.cleanup();
                }
                break;

            case 'tuneshop':
                if (window.TuneshopUI && window.TuneshopUI.cleanup) {
                    window.TuneshopUI.cleanup();
                }
                break;

            case 'tablet':
                if (window.TabletUI && window.TabletUI.cleanup) {
                    window.TabletUI.cleanup();
                }
                break;
        }
    },

    // ------------------------------------------------------------------------
    // Cerrar UI actual
    // ------------------------------------------------------------------------
    closeCurrentUI() {
        if (!this.currentUI) return;

        const uiElement = document.getElementById(`${this.currentUI}-ui`);
        if (uiElement) {
            uiElement.classList.remove('active');
        }

        // Cleanup
        this.cleanupUI(this.currentUI);
        
        Utils.log(`Closed ${this.currentUI} UI`, 'info');
        
        this.currentUI = null;

        // Notificar a Lua
        Utils.post('closeUI', {});
    },

    // ------------------------------------------------------------------------
    // Cerrar TODAS las UIs
    // ------------------------------------------------------------------------
    closeAllUIs() {
        // Cerrar UI principal
        if (this.currentUI) {
            this.closeCurrentUI();
        }

        // Cerrar install progress
        const installUI = document.getElementById('install-progress-ui');
        if (installUI) {
            installUI.classList.remove('active');
            if (window.InstallProgress) {
                InstallProgress.reset();
            }
        }

        // Cerrar radial menu
        const radialUI = document.getElementById('radial-ui');
        if (radialUI) {
            radialUI.classList.remove('show');
        }

        Utils.log('All UIs closed', 'info');
    },

    // ========================================================================
    // RADIAL MENU
    // ========================================================================
    openRadialMenu(options) {
        const radialContainer = document.getElementById('radial-ui');
        if (!radialContainer) {
            Utils.log('radial-ui element not found', 'error');
            return;
        }

        // Generar HTML
        let html = `
            <div class="hexagon-circle">
                <div class="hexagon-close" onclick="MechanicUI.closeRadialMenu()">
                    <div class="hexagon-close-button">
                        <i class="fas fa-times hexagon-close-icon"></i>
                    </div>
                </div>
        `;

        options.forEach((opt, index) => {
            html += `
                <div class="hexagon hex-${index + 1}" 
                     onclick="MechanicUI.handleRadialClick('${opt.event}', '${opt.id}')">
                    <div class="hexagon-button">
                        <div class="hexagon-content">
                            <div class="hexagon-icon-container">
                                <i class="fas ${opt.icon} hexagon-icon"></i>
                            </div>
                            <div class="hexagon-title">${opt.label}</div>
                        </div>
                    </div>
                </div>
            `;
        });

        html += `</div>`;

        radialContainer.innerHTML = html;
        radialContainer.classList.add('show');
        
        Utils.log(`Radial menu opened with ${options.length} options`, 'info');
    },

    closeRadialMenu() {
        const radialContainer = document.getElementById('radial-ui');
        if (radialContainer) {
            radialContainer.classList.remove('show');
        }
        
        Utils.post('closeRadial', {});
        Utils.log('Radial menu closed', 'info');
    },

    handleRadialClick(event, id) {
        Utils.log(`Radial clicked: ${event} (${id})`, 'info');
        Utils.post('radialClick', { event: event, id: id });
    },

    // ========================================================================
    // NOTIFICACIONES (Opcional)
    // ========================================================================
    showNotification(message, type = 'info', duration = 5000) {
        // Aquí puedes implementar tu sistema de notificaciones custom
        // O simplemente usar console.log
        Utils.log(message, type);
        
        // Ejemplo básico de notificación visual:
        // const notif = document.createElement('div');
        // notif.className = `notification notification-${type}`;
        // notif.textContent = message;
        // document.body.appendChild(notif);
        // setTimeout(() => notif.remove(), duration);
    }
};

// ----------------------------------------------------------------------------
// Inicializar cuando el DOM esté listo
// ----------------------------------------------------------------------------
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => MechanicUI.init());
} else {
    MechanicUI.init();
}

// Exponer globalmente
window.MechanicUI = MechanicUI;