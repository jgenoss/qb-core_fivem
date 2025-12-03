// ============================================================================
// QB-MECHANIC-PRO - Utilidades Globales
// Funciones auxiliares reutilizables en todos los módulos
// ============================================================================

const Utils = {
    // ------------------------------------------------------------------------
    // Obtener nombre del resource
    // ------------------------------------------------------------------------
    getResourceName() {
        if (window.GetParentResourceName) {
            return window.GetParentResourceName();
        }
        // Fallback para desarrollo
        return window.location.hostname === '' ? 'qb-mechanic-pro' : window.location.hostname;
    },

    // ------------------------------------------------------------------------
    // Comunicación NUI (JavaScript -> Lua)
    // ------------------------------------------------------------------------
    post(endpoint, data = {}) {
        const resourceName = this.getResourceName();
        
        return fetch(`https://${resourceName}/${endpoint}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        })
        .then(response => response.json())
        .catch(error => {
            console.error(`[Utils] POST error to ${endpoint}:`, error);
            return { success: false, error: error.message };
        });
    },

    // ------------------------------------------------------------------------
    // Formateo de dinero
    // ------------------------------------------------------------------------
    formatMoney(amount) {
        if (typeof amount !== 'number') {
            amount = parseFloat(amount) || 0;
        }
        
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(amount);
    },

    // Versión alternativa con símbolo $
    formatMoneySimple(amount) {
        if (typeof amount !== 'number') {
            amount = parseFloat(amount) || 0;
        }
        
        return '$' + amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    },

    // ------------------------------------------------------------------------
    // Formateo de fechas
    // ------------------------------------------------------------------------
    formatDate(dateString) {
        if (!dateString) return 'N/A';
        
        const date = new Date(dateString);
        return new Intl.DateTimeFormat('es-ES', {
            month: 'short',
            day: 'numeric',
            year: 'numeric'
        }).format(date);
    },

    formatDateTime(dateString) {
        if (!dateString) return 'N/A';
        
        const date = new Date(dateString);
        return new Intl.DateTimeFormat('es-ES', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }).format(date);
    },

    formatTimeAgo(dateString) {
        if (!dateString) return 'N/A';
        
        const date = new Date(dateString);
        const now = new Date();
        const diffMs = now - date;
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMins / 60);
        const diffDays = Math.floor(diffHours / 24);
        
        if (diffMins < 1) return 'Justo ahora';
        if (diffMins < 60) return `Hace ${diffMins} min`;
        if (diffHours < 24) return `Hace ${diffHours}h`;
        if (diffDays < 7) return `Hace ${diffDays} días`;
        
        return this.formatDate(dateString);
    },

    // ------------------------------------------------------------------------
    // Validaciones
    // ------------------------------------------------------------------------
    isValidNumber(value, min = 0, max = Infinity) {
        const num = parseFloat(value);
        return !isNaN(num) && num >= min && num <= max;
    },

    isValidString(value, minLength = 1, maxLength = Infinity) {
        return typeof value === 'string' && 
               value.trim().length >= minLength && 
               value.length <= maxLength;
    },

    isValidPlate(plate) {
        return this.isValidString(plate, 3, 10);
    },

    // ------------------------------------------------------------------------
    // Manipulación del DOM
    // ------------------------------------------------------------------------
    createElement(tag, className = '', innerHTML = '') {
        const element = document.createElement(tag);
        if (className) element.className = className;
        if (innerHTML) element.innerHTML = innerHTML;
        return element;
    },

    getElement(selector) {
        return document.querySelector(selector);
    },

    getElements(selector) {
        return document.querySelectorAll(selector);
    },

    // ------------------------------------------------------------------------
    // Escape HTML para prevenir XSS
    // ------------------------------------------------------------------------
    escapeHtml(text) {
        const map = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#039;'
        };
        return text.replace(/[&<>"']/g, m => map[m]);
    },

    // ------------------------------------------------------------------------
    // Debounce (evitar llamadas excesivas)
    // ------------------------------------------------------------------------
    debounce(func, wait = 300) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    },

    // ------------------------------------------------------------------------
    // Traducciones de modificaciones
    // ------------------------------------------------------------------------
    getModificationLabel(modType, defaultLabel = null) {
        const translations = {
            // Performance
            'engine': 'Motor',
            'brakes': 'Frenos',
            'transmission': 'Transmisión',
            'suspension': 'Suspensión',
            'turbo': 'Turbo',
            'armor': 'Blindaje',
            
            // Cosmetic
            'spoiler': 'Alerón',
            'fbumper': 'Parachoques Delantero',
            'rbumper': 'Parachoques Trasero',
            'skirts': 'Faldones Laterales',
            'exhaust': 'Escape',
            'grille': 'Parrilla',
            'hood': 'Capó',
            'roof': 'Techo',
            'fender': 'Guardabarros',
            'roll_cage': 'Jaula Antivuelco',
            
            // Wheels & Paint
            'wheels': 'Ruedas',
            'front_wheels': 'Ruedas Delanteras',
            'back_wheels': 'Ruedas Traseras',
            'wheel_color': 'Color de Ruedas',
            'primary_color': 'Color Primario',
            'secondary_color': 'Color Secundario',
            'pearlescent': 'Perlado',
            'tire_smoke': 'Humo de Neumáticos',
            
            // Lighting
            'headlights': 'Faros',
            'neon': 'Neón',
            'xenon': 'Xenón'
        };
        
        return translations[modType] || defaultLabel || modType;
    },

    // ------------------------------------------------------------------------
    // Estados de órdenes
    // ------------------------------------------------------------------------
    getOrderStatusLabel(status) {
        const statuses = {
            'pending': 'Pendiente',
            'installing': 'Instalando',
            'completed': 'Completado',
            'failed': 'Fallido',
            'cancelled': 'Cancelado'
        };
        
        return statuses[status] || status;
    },

    getOrderStatusColor(status) {
        const colors = {
            'pending': '#f59e0b',      // Amber
            'installing': '#3b82f6',   // Blue
            'completed': '#10b981',    // Green
            'failed': '#ef4444',       // Red
            'cancelled': '#6b7280'     // Gray
        };
        
        return colors[status] || '#6b7280';
    },

    // ------------------------------------------------------------------------
    // Animaciones y efectos
    // ------------------------------------------------------------------------
    fadeIn(element, duration = 300) {
        element.style.opacity = '0';
        element.style.display = 'block';
        
        let start = null;
        const animate = (timestamp) => {
            if (!start) start = timestamp;
            const progress = timestamp - start;
            const opacity = Math.min(progress / duration, 1);
            
            element.style.opacity = opacity;
            
            if (progress < duration) {
                requestAnimationFrame(animate);
            }
        };
        
        requestAnimationFrame(animate);
    },

    fadeOut(element, duration = 300) {
        let start = null;
        const animate = (timestamp) => {
            if (!start) start = timestamp;
            const progress = timestamp - start;
            const opacity = Math.max(1 - (progress / duration), 0);
            
            element.style.opacity = opacity;
            
            if (progress < duration) {
                requestAnimationFrame(animate);
            } else {
                element.style.display = 'none';
            }
        };
        
        requestAnimationFrame(animate);
    },

    // ------------------------------------------------------------------------
    // Logging mejorado
    // ------------------------------------------------------------------------
    log(message, type = 'info') {
        const prefix = '[QB-MECHANIC-PRO]';
        const styles = {
            info: 'color: #3b82f6',
            success: 'color: #10b981',
            warning: 'color: #f59e0b',
            error: 'color: #ef4444'
        };
        
        console.log(`%c${prefix} ${message}`, styles[type] || styles.info);
    }
};

// Exponer globalmente
window.Utils = Utils;

// Shortcuts para funciones más usadas
window.formatMoney = Utils.formatMoney.bind(Utils);
window.formatDate = Utils.formatDate.bind(Utils);
window.post = Utils.post.bind(Utils);
window.GetParentResourceName = Utils.getResourceName.bind(Utils);