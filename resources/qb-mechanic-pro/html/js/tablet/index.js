// ============================================================================
// QB-MECHANIC-PRO - Tablet UI
// Dashboard de gestión para mecánicos (órdenes, empleados, estadísticas)
// ============================================================================

window.TabletUI = {
    shop: null,
    currentSection: 'dashboard',
    selectedOrder: null,
    installingOrder: false,

    // ------------------------------------------------------------------------
    // Inicialización
    // ------------------------------------------------------------------------
    initialize(data) {
        this.shop = data.shop;
        this.currentSection = data.section || 'dashboard';
        this.render();
    },

    // ------------------------------------------------------------------------
    // Renderizar UI completa
    // ------------------------------------------------------------------------
    render() {
        const container = document.getElementById('tablet-ui');

        container.innerHTML = `
            <div class="tablet-container">
                <!-- HEADER -->
                <header class="tablet-header">
                    <div class="tablet-logo">
                        <i class="fas fa-tablet-alt"></i>
                        <h2>${this.shop.shop_name}</h2>
                    </div>
                    <button class="btn-close-tablet" onclick="MechanicUI.closeCurrentUI()">
                        <i class="fas fa-times"></i>
                    </button>
                </header>

                <!-- NAVIGATION -->
                <nav class="tablet-nav">
                    <button class="tablet-nav-btn ${this.currentSection === 'dashboard' ? 'active' : ''}" 
                            onclick="TabletUI.switchSection('dashboard')">
                        <i class="fas fa-chart-line"></i>
                        <span>Dashboard</span>
                    </button>
                    <button class="tablet-nav-btn ${this.currentSection === 'orders' ? 'active' : ''}" 
                            onclick="TabletUI.switchSection('orders')">
                        <i class="fas fa-clipboard-list"></i>
                        <span>Órdenes</span>
                        ${this.shop.orders?.filter(o => o.status === 'pending').length > 0 ?
                `<span class="badge">${this.shop.orders.filter(o => o.status === 'pending').length}</span>` : ''}
                    </button>
                    <button class="tablet-nav-btn ${this.currentSection === 'employees' ? 'active' : ''}" 
                            onclick="TabletUI.switchSection('employees')">
                        <i class="fas fa-users"></i>
                        <span>Empleados</span>
                    </button>
                </nav>

                <!-- CONTENT -->
                <main class="tablet-content">
                    ${this.renderContent()}
                </main>
            </div>
        `;
    },
    // Añadir al objeto TabletUI

    renderDyno() {
        const data = this.shop.dynoData || { maxSpeed: 0, acceleration: 0, force: 0, curve: [] };
        const veh = this.shop.vehicleData || { plate: 'N/A', model: 'Unknown' };

        // Preparamos el SVG de la gráfica (Simple Polyline)
        const points = data.curve.map((p, i) => {
            // Escalar puntos para que quepan en el SVG (300x200)
            const x = (i / 10) * 300;
            const y = 200 - (p.y / 800) * 200; // Asumiendo max HP 800
            return `${x},${y}`;
        }).join(' ');

        return `
        <div class="dyno-screen">
            <div class="screen-header">
                <div class="screen-title">
                    <span>Banco de Potencia</span>
                    <span class="vehicle-tag">${veh.model} - ${veh.plate}</span>
                </div>
            </div>

            <div class="dyno-content">
                <div class="dyno-chart-container">
                    <svg viewBox="0 0 300 200" class="dyno-graph">
                        <line x1="0" y1="50" x2="300" y2="50" stroke="#333" stroke-width="1" />
                        <line x1="0" y1="100" x2="300" y2="100" stroke="#333" stroke-width="1" />
                        <line x1="0" y1="150" x2="300" y2="150" stroke="#333" stroke-width="1" />
                        
                        <polyline points="${points}" fill="none" stroke="#00a3ff" stroke-width="3" />
                    </svg>
                    <div class="chart-labels">
                        <span>0 RPM</span>
                        <span>10000 RPM</span>
                    </div>
                </div>

                <div class="dyno-stats-grid">
                    <div class="stat-box">
                        <div class="stat-label">Velocidad Máx</div>
                        <div class="stat-value">${data.maxSpeed} <small>km/h</small></div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-label">Inercia</div>
                        <div class="stat-value">${data.acceleration}</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-label">Fuerza de Tracción</div>
                        <div class="stat-value">${data.force} <small>G</small></div>
                    </div>
                </div>
            </div>
        </div>
    `;
    },
    // ------------------------------------------------------------------------
    // Renderizar contenido según sección
    // ------------------------------------------------------------------------
    renderContent() {
        switch (this.currentSection) {
            case 'dashboard':
                return this.renderDashboard();
            case 'orders':
                return this.renderOrders();
            case 'employees':
                return this.renderEmployees();
            case 'dyno':
                return this.renderDyno();
            default:
                return '';
        }
    },

    // ------------------------------------------------------------------------
    // DASHBOARD
    // ------------------------------------------------------------------------
    renderDashboard() {
        const stats = this.shop.stats || {};

        return `
            <div class="dashboard-grid">
                <!-- Stats Cards -->
                <div class="stats-cards">
                    <div class="stat-card">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #667eea, #764ba2);">
                            <i class="fas fa-clipboard-check"></i>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value">${stats.totalOrders || 0}</div>
                            <div class="stat-label">Total Órdenes</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #10b981, #22c55e);">
                            <i class="fas fa-check-circle"></i>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value">${stats.completedOrders || 0}</div>
                            <div class="stat-label">Completadas</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #f59e0b, #ef4444);">
                            <i class="fas fa-users"></i>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value">${stats.totalEmployees || 0}</div>
                            <div class="stat-label">Empleados</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #06b6d4, #3b82f6);">
                            <i class="fas fa-dollar-sign"></i>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value">${this.formatMoney(stats.totalRevenue || 0)}</div>
                            <div class="stat-label">Ingresos Totales</div>
                        </div>
                    </div>
                </div>

                <!-- Recent Orders -->
                <div class="recent-section">
                    <h3 class="section-title">
                        <i class="fas fa-clock"></i> Órdenes Recientes
                    </h3>
                    ${this.renderRecentOrders()}
                </div>
            </div>
        `;
    },

    renderRecentOrders() {
        const recentOrders = (this.shop.orders || []).slice(0, 5);

        if (recentOrders.length === 0) {
            return `
                <div class="empty-state">
                    <i class="fas fa-inbox"></i>
                    <p>No hay órdenes recientes</p>
                </div>
            `;
        }

        return `
            <div class="orders-list">
                ${recentOrders.map(order => `
                    <div class="order-item" onclick="TabletUI.viewOrder('${order.id}')">
                        <div class="order-info">
                            <div class="order-customer">
                                <i class="fas fa-user"></i>
                                ${order.customer_name}
                            </div>
                            <div class="order-vehicle">
                                <i class="fas fa-car"></i>
                                ${order.vehicle_model} - ${order.vehicle_plate}
                            </div>
                        </div>
                        <div class="order-meta">
                            <span class="order-status status-${order.status}">${order.status}</span>
                            <span class="order-amount">${this.formatMoney(order.total_cost)}</span>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
    },

    // ------------------------------------------------------------------------
    // ORDERS
    // ------------------------------------------------------------------------
    renderOrders() {
        const pendingOrders = (this.shop.orders || []).filter(o => o.status === 'pending');

        return `
            <div class="orders-section">
                <div class="section-header">
                    <h3 class="section-title">
                        <i class="fas fa-clipboard-list"></i> Órdenes Pendientes
                    </h3>
                </div>

                ${pendingOrders.length === 0 ? `
                    <div class="empty-state">
                        <i class="fas fa-check-circle"></i>
                        <p>No hay órdenes pendientes</p>
                        <small>Las órdenes aparecerán aquí cuando los clientes compren modificaciones</small>
                    </div>
                ` : `
                    <div class="orders-grid">
                        ${pendingOrders.map(order => this.renderOrderCard(order)).join('')}
                    </div>
                `}
            </div>
        `;
    },

    renderOrderCard(order) {
        const modifications = JSON.parse(order.modifications || '[]');

        return `
            <div class="order-card">
                <div class="order-card-header">
                    <div>
                        <div class="order-id">Orden #${order.id}</div>
                        <div class="order-date">${this.formatDate(order.created_at)}</div>
                    </div>
                    <div class="order-status-badge status-${order.status}">
                        ${order.status}
                    </div>
                </div>

                <div class="order-card-body">
                    <div class="order-detail">
                        <i class="fas fa-user"></i>
                        <span>${order.customer_name}</span>
                    </div>
                    <div class="order-detail">
                        <i class="fas fa-car"></i>
                        <span>${order.vehicle_model} - ${order.vehicle_plate}</span>
                    </div>
                    <div class="order-detail">
                        <i class="fas fa-wrench"></i>
                        <span>${modifications.length} modificaciones</span>
                    </div>
                </div>

                <div class="order-card-footer">
                    <div class="order-total">${this.formatMoney(order.total_cost)}</div>
                    <button class="btn-install" onclick="TabletUI.installOrder('${order.id}')">
                        <i class="fas fa-tools"></i> Instalar
                    </button>
                </div>
            </div>
        `;
    },

    // ------------------------------------------------------------------------
    // EMPLOYEES
    // ------------------------------------------------------------------------
    renderEmployees() {
        const employees = this.shop.employees || [];

        return `
            <div class="employees-section">
                <div class="section-header">
                    <h3 class="section-title">
                        <i class="fas fa-users"></i> Gestión de Empleados
                    </h3>
                    <button class="btn-primary" onclick="TabletUI.showHireModal()">
                        <i class="fas fa-plus"></i> Contratar Empleado
                    </button>
                </div>

                ${employees.length === 0 ? `
                    <div class="empty-state">
                        <i class="fas fa-user-plus"></i>
                        <p>No hay empleados contratados</p>
                        <small>Usa el botón de arriba para contratar nuevos empleados</small>
                    </div>
                ` : `
                    <div class="employees-grid">
                        ${employees.map(emp => this.renderEmployeeCard(emp)).join('')}
                    </div>
                `}
            </div>
        `;
    },

    renderEmployeeCard(employee) {
        return `
            <div class="employee-card">
                <div class="employee-avatar">
                    <i class="fas fa-user-circle"></i>
                </div>
                <div class="employee-info">
                    <div class="employee-name">${employee.employee_name}</div>
                    <div class="employee-meta">
                        <span class="employee-grade">Grado ${employee.job_grade}</span>
                        <span class="employee-date">${this.formatDate(employee.hired_at)}</span>
                    </div>
                </div>
                <button class="btn-fire" onclick="TabletUI.fireEmployee('${employee.citizenid}', '${employee.employee_name}')">
                    <i class="fas fa-user-times"></i>
                </button>
            </div>
        `;
    },

    // ------------------------------------------------------------------------
    // Acciones
    // ------------------------------------------------------------------------
    switchSection(section) {
        this.currentSection = section;
        this.render();
    },

    viewOrder(orderId) {
        this.selectedOrder = this.shop.orders.find(o => o.id == orderId);
        this.switchSection('orders');
    },

    installOrder(orderId) {
        const order = this.shop.orders.find(o => o.id == orderId);
        if (!order) return;

        if (confirm(`¿Instalar modificaciones para ${order.vehicle_model} (${order.vehicle_plate})?`)) {
            this.installingOrder = true;

            MechanicUI.post('installOrder', {
                orderId: orderId,
                vehiclePlate: order.vehicle_plate,
                modifications: JSON.parse(order.modifications)
            }).then(response => {
                this.installingOrder = false;

                if (response.success) {
                    MechanicUI.showNotification('Orden completada exitosamente', 'success');
                    // Recargar datos
                    MechanicUI.post('requestShopData', { shopId: this.shop.id });
                } else {
                    MechanicUI.showNotification(response.message || 'Error al instalar', 'error');
                }
            });
        }
    },

    updateInstallProgress(data) {
        // Mostrar progreso de instalación
        console.log(`Installing ${data.step}/${data.total}: ${data.current.label}`);
    },

    showHireModal() {
        const serverId = prompt('Introduce el ID del servidor del jugador a contratar:');

        if (serverId && serverId.trim() !== '') {
            MechanicUI.post('hireEmployee', {
                shopId: this.shop.id,
                targetServerId: parseInt(serverId)
            }).then(response => {
                if (response.success) {
                    MechanicUI.showNotification('Empleado contratado exitosamente', 'success');
                    // Recargar datos
                    MechanicUI.post('requestShopData', { shopId: this.shop.id });
                } else {
                    MechanicUI.showNotification(response.message || 'Error al contratar', 'error');
                }
            });
        }
    },

    fireEmployee(citizenid, name) {
        if (confirm(`¿Despedir a ${name}?`)) {
            MechanicUI.post('fireEmployee', {
                shopId: this.shop.id,
                employeeCitizenid: citizenid
            }).then(response => {
                if (response.success) {
                    MechanicUI.showNotification('Empleado despedido', 'success');
                    // Recargar datos
                    MechanicUI.post('requestShopData', { shopId: this.shop.id });
                } else {
                    MechanicUI.showNotification(response.message || 'Error al despedir', 'error');
                }
            });
        }
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
            hour: '2-digit',
            minute: '2-digit'
        }).format(date);
    },

    cleanup() {
        this.selectedOrder = null;
        this.installingOrder = false;
    }
};