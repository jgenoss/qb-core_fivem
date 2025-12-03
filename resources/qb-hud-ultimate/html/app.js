const app = new Vue({
    el: '#app',
    data: {
        show: false,
        editing: false,
        activeTab: 'position',

        positions: {},
        bgOpacity: {
            player: 4.0,
            vehicle: 9.5,
            money: 9.2,
            badge: 8.5
        },
        scale: {
            player: 100,
            vehicle: 100,
            money: 100
        },

        draggingType: null,
        dragOffset: { x: 0, y: 0 },
        snapThreshold: 10, // Reducido para mejor precisión

        // Dimensiones aproximadas de cada elemento (en píxeles sin escala)
        elementSizes: {
            player: { width: 350, height: 60 },
            vehicle: { width: 320, height: 240 },
            money: { width: 280, height: 60 }
        },

        stats: {
            id: 0, money: 0, bank: 0,
            voice: 33, talking: false,
            health: 100, armor: 0, stamina: 100, hunger: 100, thirst: 100, stress: 0, oxygen: 100,

            inVehicle: false, isBicycle: false, isMotorcycle: false,
            speed: 0, rpm: 0, gear: 0,
            fuel: 0, temp: 0, oil: 0, pressure: 0, engine: 100, body: 100,
            seatbelt: false, handbrake: false, doorOpen: false,
            coolant: 100, // NUEVO
            odometer: 0,  // NUEVO
            engineOn: false,  // NUEVO
            battery: 100,

            street: '', direction: 'N',
            lights: { low: false, high: false, left: false, right: false }
        }
    },

    created() {
        this.loadSettings();
    },

    computed: {
        computedGear() {
            const gear = this.stats.gear;
            const speed = this.stats.speed;
            const rpm = this.stats.rpm;

            if (speed < 2 && rpm < 0.25) return "N";
            if (gear === 0) return "R";
            return gear;
        }
    },

    methods: {
        loadSettings() {
            const savedPos = localStorage.getItem('qb-hud-ultimate-pos');
            const defaultPos = {
                player: { x: window.innerWidth / 2 - 150, y: 25, vertical: false },
                vehicle: { x: window.innerWidth - 350, y: 25 },
                money: { x: 20, y: window.innerHeight - 150, vertical: false }
            };

            if (!savedPos) {
                this.positions = defaultPos;
            } else {
                try {
                    this.positions = JSON.parse(savedPos);

                    for (let key in defaultPos) {
                        if (!this.positions[key]) {
                            this.positions[key] = defaultPos[key];
                        }
                    }

                    if (this.positions.money && this.positions.money.vertical === undefined) {
                        this.positions.money.vertical = false;
                    }
                } catch (e) {
                    console.error('[HUD] Error cargando posiciones:', e);
                    this.positions = defaultPos;
                }
            }

            const savedBgOpacity = localStorage.getItem('qb-hud-bg-opacity');
            if (savedBgOpacity) {
                try {
                    const loaded = JSON.parse(savedBgOpacity);
                    this.bgOpacity = { ...this.bgOpacity, ...loaded };
                } catch (e) {
                    console.error('[HUD] Error cargando opacidades:', e);
                }
            }

            const savedScale = localStorage.getItem('qb-hud-scale');
            if (savedScale) {
                try {
                    const loaded = JSON.parse(savedScale);
                    this.scale = { ...this.scale, ...loaded };
                } catch (e) {
                    console.error('[HUD] Error cargando escalas:', e);
                }
            }
        },
        formatOdometer(km) {
            if (km === undefined || km === null) return "0";
            return new Intl.NumberFormat('es-ES').format(km);
        },
        formatMoney(val) {
            if (val === undefined || val === null) return "0";
            return new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD',
                minimumFractionDigits: 0
            }).format(val).replace('$', '');
        },

        resetAppearance() {
            this.bgOpacity = {
                player: 4.0,
                vehicle: 9.5,
                money: 9.2,
                badge: 8.5
            };
            this.scale = {
                player: 100,
                vehicle: 100,
                money: 100
            };
        },

        resetPositions() {
            const defaults = {
                player: { x: window.innerWidth / 2 - 150, y: 25, vertical: false },
                vehicle: { x: window.innerWidth - 350, y: 25 },
                money: { x: 20, y: window.innerHeight - 150, vertical: false }
            };
            this.positions = defaults;
        },

        startDrag(type, e) {
            if (!this.editing) return;

            this.draggingType = type;
            const el = e.target.closest('.draggable-container');
            const rect = el.getBoundingClientRect();

            this.dragOffset.x = e.clientX - rect.left;
            this.dragOffset.y = window.innerHeight - e.clientY - this.positions[type].y;

            window.addEventListener('mousemove', this.onDrag);
            window.addEventListener('mouseup', this.stopDrag);
        },

        onDrag(e) {
            if (!this.draggingType) return;

            let rawX = e.clientX - this.dragOffset.x;
            let rawY = (window.innerHeight - e.clientY) - this.dragOffset.y;

            const snapped = this.calculateAdvancedSnap(this.draggingType, rawX, rawY);
            const currentVertical = this.positions[this.draggingType].vertical || false;

            this.$set(this.positions, this.draggingType, {
                x: snapped.x,
                y: snapped.y,
                vertical: currentVertical
            });
        },

        /**
         * SISTEMA MAGNÉTICO AVANZADO
         * Detecta: bordes, centros, alineaciones y límites de pantalla
         */
        calculateAdvancedSnap(currentType, x, y) {
            const threshold = this.snapThreshold;
            let finalX = x;
            let finalY = y;

            // Obtener dimensiones del elemento actual (con escala aplicada)
            const currentScale = this.scale[currentType] / 100;
            const currentSize = this.elementSizes[currentType] || { width: 200, height: 60 };
            const currentWidth = currentSize.width * currentScale;
            const currentHeight = currentSize.height * currentScale;

            // Calcular bordes del elemento actual
            const currentLeft = x;
            const currentRight = x + currentWidth;
            const currentBottom = y;
            const currentTop = y + currentHeight;
            const currentCenterX = x + (currentWidth / 2);
            const currentCenterY = y + (currentHeight / 2);

            // ========================================
            // 1. SNAP A BORDES DE PANTALLA
            // ========================================

            // Borde izquierdo de pantalla
            if (Math.abs(currentLeft) < threshold) {
                finalX = 0;
            }

            // Borde derecho de pantalla
            if (Math.abs(currentRight - window.innerWidth) < threshold) {
                finalX = window.innerWidth - currentWidth;
            }

            // Borde inferior de pantalla
            if (Math.abs(currentBottom) < threshold) {
                finalY = 0;
            }

            // Borde superior de pantalla
            if (Math.abs(currentTop - window.innerHeight) < threshold) {
                finalY = window.innerHeight - currentHeight;
            }

            // Centro horizontal de pantalla
            if (Math.abs(currentCenterX - (window.innerWidth / 2)) < threshold) {
                finalX = (window.innerWidth / 2) - (currentWidth / 2);
            }

            // Centro vertical de pantalla
            if (Math.abs(currentCenterY - (window.innerHeight / 2)) < threshold) {
                finalY = (window.innerHeight / 2) - (currentHeight / 2);
            }

            // ========================================
            // 2. SNAP A OTROS ELEMENTOS
            // ========================================

            const otherElements = Object.keys(this.positions).filter(k => k !== currentType);

            for (let otherKey of otherElements) {
                const other = this.positions[otherKey];
                const otherScale = this.scale[otherKey] / 100;
                const otherSize = this.elementSizes[otherKey] || { width: 200, height: 60 };
                const otherWidth = otherSize.width * otherScale;
                const otherHeight = otherSize.height * otherScale;

                // Calcular bordes del otro elemento
                const otherLeft = other.x;
                const otherRight = other.x + otherWidth;
                const otherBottom = other.y;
                const otherTop = other.y + otherHeight;
                const otherCenterX = other.x + (otherWidth / 2);
                const otherCenterY = other.y + (otherHeight / 2);

                // --- SNAP HORIZONTAL ---

                // Borde izquierdo con borde izquierdo
                if (Math.abs(currentLeft - otherLeft) < threshold) {
                    finalX = otherLeft;
                }

                // Borde izquierdo con borde derecho
                if (Math.abs(currentLeft - otherRight) < threshold) {
                    finalX = otherRight;
                }

                // Borde derecho con borde izquierdo
                if (Math.abs(currentRight - otherLeft) < threshold) {
                    finalX = otherLeft - currentWidth;
                }

                // Borde derecho con borde derecho
                if (Math.abs(currentRight - otherRight) < threshold) {
                    finalX = otherRight - currentWidth;
                }

                // Centro horizontal con centro horizontal
                if (Math.abs(currentCenterX - otherCenterX) < threshold) {
                    finalX = otherCenterX - (currentWidth / 2);
                }

                // --- SNAP VERTICAL ---

                // Borde inferior con borde inferior
                if (Math.abs(currentBottom - otherBottom) < threshold) {
                    finalY = otherBottom;
                }

                // Borde inferior con borde superior
                if (Math.abs(currentBottom - otherTop) < threshold) {
                    finalY = otherTop;
                }

                // Borde superior con borde inferior
                if (Math.abs(currentTop - otherBottom) < threshold) {
                    finalY = otherBottom - currentHeight;
                }

                // Borde superior con borde superior
                if (Math.abs(currentTop - otherTop) < threshold) {
                    finalY = otherTop - currentHeight;
                }

                // Centro vertical con centro vertical
                if (Math.abs(currentCenterY - otherCenterY) < threshold) {
                    finalY = otherCenterY - (currentHeight / 2);
                }
            }

            // ========================================
            // 3. LÍMITES (Evitar que salga de pantalla)
            // ========================================

            finalX = Math.max(0, Math.min(finalX, window.innerWidth - currentWidth));
            finalY = Math.max(0, Math.min(finalY, window.innerHeight - currentHeight));

            return { x: finalX, y: finalY };
        },

        stopDrag() {
            this.draggingType = null;
            window.removeEventListener('mousemove', this.onDrag);
            window.removeEventListener('mouseup', this.stopDrag);
        },

        toggleOrientation(type) {
            if (this.positions[type]) {
                this.$set(this.positions[type], 'vertical', !this.positions[type].vertical);

                // Actualizar dimensiones si cambia orientación
                if (type === 'player') {
                    if (this.positions[type].vertical) {
                        this.elementSizes.player = { width: 60, height: 350 };
                    } else {
                        this.elementSizes.player = { width: 350, height: 60 };
                    }
                }

                if (type === 'money') {
                    if (this.positions[type].vertical) {
                        this.elementSizes.money = { width: 140, height: 140 };
                    } else {
                        this.elementSizes.money = { width: 280, height: 60 };
                    }
                }
            }
        },

        finishEdit() {
            this.editing = false;

            localStorage.setItem('qb-hud-ultimate-pos', JSON.stringify(this.positions));
            localStorage.setItem('qb-hud-bg-opacity', JSON.stringify(this.bgOpacity));
            localStorage.setItem('qb-hud-scale', JSON.stringify(this.scale));

            fetch(`https://${GetParentResourceName()}/closeEdit`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });

            console.log('[HUD] Configuración guardada:', {
                positions: this.positions,
                bgOpacity: this.bgOpacity,
                scale: this.scale
            });
        }
    },

    mounted() {
        window.addEventListener('message', (event) => {
            const data = event.data;

            if (data.action === "updateHUD") {
                this.show = data.show;
                Object.assign(this.stats, data);

                if (data.isEditMode !== undefined && data.isEditMode !== this.editing) {
                    this.editing = data.isEditMode;
                }
            }
            else if (data.action === "toggleHUD") {
                this.show = data.show;
            }
            else if (data.action === "toggleEditMode") {
                this.editing = data.status;
            }
        });
    }
});