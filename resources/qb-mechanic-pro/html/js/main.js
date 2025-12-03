// ============================================================================
// QB-MECHANIC-PRO - Main UI Controller
// Gestión de navegación entre UIs y comunicación NUI
// ============================================================================

const MechanicUI = {
    currentUI: null,
    resourceName: null,

    // ------------------------------------------------------------------------
    // Inicialización
    // ------------------------------------------------------------------------
    init() {
        this.resourceName = this.getResourceName();
        this.setupEventListeners();

        console.log('[QB-MECHANIC-PRO] UI System initialized');
    },

    // ------------------------------------------------------------------------
    // Obtener nombre del resource
    // ------------------------------------------------------------------------
    getResourceName() {
        if (window.GetParentResourceName) {
            return window.GetParentResourceName();
        }
        return 'qb-mechanic-pro'; // Fallback para desarrollo
    },

    // ------------------------------------------------------------------------
    // Setup de event listeners
    // ------------------------------------------------------------------------
    setupEventListeners() {
        // Escuchar mensajes desde Lua
        window.addEventListener('message', (event) => {
            const data = event.data;

            switch (data.action) {
                case 'openCreator':
                    this.openUI('creator', data);
                    break;

                case 'openTuneshop':
                    this.openUI('tuneshop', data);
                    break;

                case 'openTablet':
                    this.openUI('tablet', data);
                    break;

                case 'updateInstallProgress':
                    if (window.TabletUI) {
                        window.TabletUI.updateInstallProgress(data);
                    }
                    break;
                case 'openRadial':
                    this.openRadialMenu(data.options);
                    break;

                case 'closeRadial':
                    this.closeRadialMenu();
                    break;

                case 'closeUI':
                    this.closeCurrentUI();
                    break;
            }
        });

        // Cerrar UI con ESC
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.currentUI) {
                this.closeCurrentUI();
            }
        });
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
            console.error(`UI "${uiName}" not found`);
            return;
        }

        // Mostrar UI
        uiElement.classList.add('active');
        this.currentUI = uiName;

        // Inicializar UI específica
        switch (uiName) {
            case 'creator':
                if (window.CreatorUI) {
                    window.CreatorUI.initialize(data);
                }
                break;

            case 'tuneshop':
                if (window.TuneshopUI) {
                    window.TuneshopUI.initialize(data);
                }
                break;

            case 'tablet':
                if (window.TabletUI) {
                    window.TabletUI.initialize(data);
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

        // Cleanup UI específica
        switch (this.currentUI) {
            case 'creator':
                if (window.CreatorUI) {
                    window.CreatorUI.cleanup();
                }
                break;

            case 'tuneshop':
                if (window.TuneshopUI) {
                    window.TuneshopUI.cleanup();
                }
                break;

            case 'tablet':
                if (window.TabletUI) {
                    window.TabletUI.cleanup();
                }
                break;
        }

        this.currentUI = null;

        // Notificar a Lua que se cerró la UI
        this.post('closeUI', {});
    },
    // Funciones para el Menú Radial
    openRadialMenu(options) {
        const radialContainer = document.getElementById('radial-ui'); // Asegúrate de crear este div en index.html si no existe
        if (!radialContainer) return;

        // Generar HTML de los hexágonos basado en las opciones
        let html = `<div class="hexagon-circle">
                    <div class="hexagon-close" onclick="MechanicUI.post('closeRadial', {})">
                        <div class="hexagon-close-button"><i class="fas fa-times hexagon-close-icon"></i></div>
                    </div>`;

        // Posicionamiento de hexágonos (simplificado)
        options.forEach((opt, index) => {
            // Calcular posición (puedes ajustar clases CSS para posicionar los 6 hexágonos)
            // Aquí asumimos que el CSS maneja :nth-child o clases específicas
            html += `
            <div class="hexagon hex-${index + 1}" onclick="MechanicUI.handleRadialClick('${opt.event}', '${opt.id}')">
                <div class="hexagon-button">
                    <div class="hexagon-content">
                        <div class="hexagon-icon-container"><i class="fas ${opt.icon} hexagon-icon"></i></div>
                        <div class="hexagon-title">${opt.label}</div>
                    </div>
                </div>
            </div>
        `;
        });

        html += `</div>`;

        radialContainer.innerHTML = html;
        radialContainer.classList.add('show'); // Clase CSS para mostrar
    },

    closeRadialMenu() {
        const radialContainer = document.getElementById('radial-ui');
        if (radialContainer) {
            radialContainer.classList.remove('show');
        }
        this.post('closeRadial', {});
    },

    handleRadialClick(event, id) {
        this.post('radialClick', { event: event, id: id });
    },
    // ------------------------------------------------------------------------
    // Comunicación NUI (JavaScript -> Lua)
    // ------------------------------------------------------------------------
    post(endpoint, data) {
        return fetch(`https://${this.resourceName}/${endpoint}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        }).then(resp => resp.json());
    },

    // ------------------------------------------------------------------------
    // Utilidades
    // ------------------------------------------------------------------------
    formatMoney(amount) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0
        }).format(amount);
    },

    formatDate(dateString) {
        const date = new Date(dateString);
        return new Intl.DateTimeFormat('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }).format(date);
    },

    showNotification(message, type = 'info') {
        // Implementar sistema de notificaciones si es necesario
        console.log(`[${type.toUpperCase()}] ${message}`);
    }
};

// ----------------------------------------------------------------------------
// Inicializar cuando el DOM esté listo
// ----------------------------------------------------------------------------
document.addEventListener('DOMContentLoaded', () => {
    MechanicUI.init();
});

// Exponer globalmente
window.MechanicUI = MechanicUI;