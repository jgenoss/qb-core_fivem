new Vue({
    el: '#app',
    data: {
        menuVisible: false,
        showSettings: false,
        isDragging: false,
        dragOffset: { x: 0, y: 0 },
        isRotatingCamera: false,
        
        // Configuración de UI
        ui: {
            top: 100,
            left: 100,
            scale: 1.0,
            opacity: 0.95
        },

        vehicleData: {
            model: '',
            plate: '',
            doors: [],
            windows: [],
            lights: {}
        }
    },
    computed: {
        containerStyle() {
            return {
                top: this.ui.top + 'px',
                left: this.ui.left + 'px',
                transform: `scale(${this.ui.scale})`,
                opacity: this.ui.opacity,
                transformOrigin: 'top left',
                position: 'fixed'
            }
        }
    },
    methods: {
        // ============================
        // CONTROL DE CÁMARA
        // ============================
        startCameraRotation(e) {
            // Solo si es click derecho (botón 2)
            if (e.button === 2) {
                this.isRotatingCamera = true;
                this.post('cameraControl', { state: 'moving' });
            }
        },

        stopCameraRotation(e) {
            // Si soltamos click derecho y estábamos rotando
            if (e.button === 2 && this.isRotatingCamera) {
                this.isRotatingCamera = false;
                this.post('cameraControl', { state: 'static' });
            }
        },

        // ============================
        // ARRASTRE DEL MENÚ
        // ============================
        startDrag(e) {
            // Solo permitir arrastre con click izquierdo (botón 0)
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

        // ============================
        // GUARDADO DE CONFIG
        // ============================
        loadSettings() {
            const saved = localStorage.getItem('vehicleMenuSettings');
            if (saved) {
                try {
                    this.ui = { ...this.ui, ...JSON.parse(saved) };
                } catch(e) {}
            } else {
                // Centrar por defecto
                this.ui.top = (window.innerHeight / 2) - 200;
                this.ui.left = (window.innerWidth / 2) - 160;
            }
        },

        saveSettings() {
            localStorage.setItem('vehicleMenuSettings', JSON.stringify(this.ui));
        },

        resetSettings() {
            this.ui.scale = 1.0;
            this.ui.opacity = 0.95;
            this.ui.top = (window.innerHeight / 2) - 200;
            this.ui.left = (window.innerWidth / 2) - 160;
            this.saveSettings();
        },

        toggleSettings() {
            this.showSettings = !this.showSettings;
        },

        // ============================
        // ACCIONES VEHÍCULO
        // ============================
        getDoorIcon(index, isOpen) {
            if (index === 4) return isOpen ? 'fa-car-burst' : 'fa-car';
            if (index === 5) return isOpen ? 'fa-box-open' : 'fa-box'; 
            return isOpen ? 'fa-door-open' : 'fa-door-closed';
        },

        toggleIndicator(side) { this.post('toggleIndicator', { side: side }); },
        toggleInteriorLight() { this.post('toggleInteriorLight', {}); },
        toggleDoor(doorIndex) { this.post('toggleDoor', { doorIndex: doorIndex }); },
        toggleWindow(windowIndex) { this.post('toggleWindow', { windowIndex: windowIndex }); },
        toggleEngine() { this.post('toggleEngine', {}); },
        
        closeMenu() {
            this.showSettings = false;
            this.post('closeMenu', {});
        },

        // ============================
        // COMUNICACIÓN
        // ============================
        post(endpoint, data) {
            let resourceName = 'qb-vehiclecontrols';
            if (window.GetParentResourceName) {
                resourceName = window.GetParentResourceName();
            }
            axios.post(`https://${resourceName}/${endpoint}`, data).catch(()=>{});
        }
    },
    mounted() {
        this.loadSettings();
        
        // Listeners Globales
        window.addEventListener('mousedown', this.startCameraRotation);
        window.addEventListener('mouseup', this.stopCameraRotation);
        // Evitar menú contextual con click derecho
        window.addEventListener('contextmenu', e => e.preventDefault());

        window.addEventListener('message', (event) => {
            const data = event.data;
            if (data.action === 'openMenu') {
                this.menuVisible = true;
                this.vehicleData = data.vehicleData;
            } else if (data.action === 'closeMenu') {
                this.menuVisible = false;
                this.isRotatingCamera = false;
            } else if (data.action === 'updateVehicleData') {
                this.vehicleData = data.vehicleData;
            }
        });

        document.addEventListener('keydown', (e) => {
            if (this.menuVisible && e.key === 'Escape') {
                this.closeMenu();
            }
        });
    }
});