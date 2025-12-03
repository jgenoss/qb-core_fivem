// ============================================================================
// QB-MECHANIC-PRO - Install Progress System
// Módulo independiente para manejar la barra de progreso de instalación
// ============================================================================

const InstallProgress = {
    currentOrder: null,
    isActive: false,
    
    // ------------------------------------------------------------------------
    // Mostrar UI de progreso
    // ------------------------------------------------------------------------
    show(orderData) {
        const ui = document.getElementById('install-progress-ui');
        if (!ui) {
            Utils.log('install-progress-ui element not found', 'error');
            return;
        }
        
        // Guardar datos de la orden
        this.currentOrder = orderData.order;
        this.isActive = true;
        
        const total = this.currentOrder.modifications.length;
        const orderId = this.currentOrder.id;
        const plate = this.currentOrder.vehicle_plate;
        
        // Generar HTML
        ui.innerHTML = this.generateHTML(orderId, plate, total);
        
        // Mostrar con animación
        ui.classList.add('active');
        
        Utils.log(`Install progress started for order #${orderId}`, 'info');
    },
    
    // ------------------------------------------------------------------------
    // Actualizar progreso
    // ------------------------------------------------------------------------
    update(data) {
        if (!this.isActive) return;
        
        const bar = document.getElementById('install-progress-bar');
        const display = document.getElementById('current-mod-display');
        
        if (!bar || !display) {
            Utils.log('Install progress elements not found', 'warning');
            return;
        }
        
        const percent = (data.step / data.total) * 100;
        
        // Actualizar barra
        bar.style.width = percent + '%';
        bar.textContent = `${data.step} / ${data.total}`;
        
        // Actualizar modificación actual
        const modLabel = Utils.getModificationLabel(
            data.current.type, 
            data.current.label
        );
        
        display.innerHTML = `
            <strong>Instalando:</strong>
            <span>${modLabel}</span>
        `;
        
        Utils.log(`Progress: ${data.step}/${data.total} - ${modLabel}`, 'info');
    },
    
    // ------------------------------------------------------------------------
    // Ocultar UI
    // ------------------------------------------------------------------------
    hide() {
        if (!this.isActive) return;
        
        const ui = document.getElementById('install-progress-ui');
        if (!ui) return;
        
        // Mostrar mensaje de finalización
        const display = document.getElementById('current-mod-display');
        if (display) {
            display.innerHTML = `
                <strong style="color: #86efac;">
                    <i class="fas fa-check-circle"></i> Instalación Completada
                </strong>
                <span>Todas las modificaciones fueron aplicadas exitosamente</span>
            `;
        }
        
        // Cambiar color de la barra a verde
        const bar = document.getElementById('install-progress-bar');
        if (bar) {
            bar.style.background = 'linear-gradient(90deg, #059669, #10b981, #34d399)';
        }
        
        // Ocultar después de 2.5 segundos
        setTimeout(() => {
            ui.classList.remove('active');
            this.reset();
        }, 2500);
        
        Utils.log('Install progress completed', 'success');
    },
    
    // ------------------------------------------------------------------------
    // Reset del sistema
    // ------------------------------------------------------------------------
    reset() {
        this.currentOrder = null;
        this.isActive = false;
    },
    
    // ------------------------------------------------------------------------
    // Generar HTML de la UI
    // ------------------------------------------------------------------------
    generateHTML(orderId, plate, total) {
        return `
            <div class="install-header">
                <h2>
                    <i class="fas fa-tools"></i> 
                    Instalando Modificaciones
                </h2>
                <p>Orden #${orderId} - Placa: <strong>${plate}</strong></p>
            </div>
            
            <div class="progress-bar-container">
                <div class="progress-bar-fill" id="install-progress-bar" style="width: 0%">
                    0 / ${total}
                </div>
            </div>
            
            <div class="current-mod" id="current-mod-display">
                <strong>
                    <i class="fas fa-cog fa-spin"></i> 
                    Iniciando instalación...
                </strong>
                <span>Preparando herramientas y verificando vehículo</span>
            </div>
            
            <div class="install-footer">
                <small>
                    <i class="fas fa-info-circle"></i> 
                    No muevas el vehículo durante la instalación
                </small>
            </div>
        `;
    },
    
    // ------------------------------------------------------------------------
    // Mostrar error
    // ------------------------------------------------------------------------
    showError(message) {
        const ui = document.getElementById('install-progress-ui');
        if (!ui) return;
        
        const display = document.getElementById('current-mod-display');
        if (display) {
            display.innerHTML = `
                <strong style="color: #fca5a5;">
                    <i class="fas fa-exclamation-triangle"></i> Error
                </strong>
                <span>${message}</span>
            `;
        }
        
        // Ocultar después de 3 segundos
        setTimeout(() => {
            ui.classList.remove('active');
            this.reset();
        }, 3000);
        
        Utils.log(`Install error: ${message}`, 'error');
    }
};

// Exponer globalmente
window.InstallProgress = InstallProgress;