-- ============================================================================
-- QB-MECHANIC-PRO - Traducciones en Español
-- ============================================================================

Locale = Locale or {}
Locale['es'] = {
    -- ========================================================================
    -- GENERAL
    -- ========================================================================
    ['shop_name'] = 'Taller Mecánico',
    ['blip_name'] = 'Mecánico',
    ['enter_zone'] = 'Presiona ~INPUT_CONTEXT~ para abrir el menú',
    ['close_ui'] = 'Presiona ~INPUT_CANCEL~ para cerrar',
    
    -- ========================================================================
    -- CREATOR UI
    -- ========================================================================
    ['creator_title'] = 'Creador de Talleres Mecánicos',
    ['creator_statistics'] = 'Estadísticas',
    ['creator_mechanics'] = 'Mecánicos',
    ['creator_create_new'] = 'Crear Nuevo',
    
    -- Basic Information
    ['creator_basic_info'] = 'Información Básica',
    ['creator_shop_name'] = 'Nombre del Taller',
    ['creator_shop_name_placeholder'] = 'Taller Original de Benny',
    ['creator_ownership_type'] = 'Tipo de Propiedad',
    ['creator_ownership_public'] = 'Público',
    ['creator_ownership_job'] = 'Restringido por Trabajo',
    ['creator_job_name'] = 'Nombre del Trabajo',
    ['creator_job_name_placeholder'] = 'mecanico',
    ['creator_minimum_grade'] = 'Grado Mínimo',
    ['creator_boss_grade'] = 'Grado de Jefe (Acceso de Gestión)',
    ['creator_boss_grade_desc'] = 'Grado requerido para acceder a Gestión y Configuración en la tablet',
    
    -- Locations
    ['creator_locations'] = 'Ubicaciones',
    ['creator_duty_location'] = 'Ubicación de Servicio',
    ['creator_stash_location'] = 'Ubicación de Almacén',
    ['creator_bossmenu_location'] = 'Ubicación de Menú Jefe',
    ['creator_tuneshop_locations'] = 'Ubicaciones de Taller de Tuning',
    ['creator_carlift_locations'] = 'Ubicaciones de Elevador',
    ['creator_add_location'] = 'Agregar Ubicación',
    ['creator_set_location'] = 'Establecer Posición Actual',
    ['creator_teleport'] = 'Teletransportar',
    ['creator_remove'] = 'Eliminar',
    
    -- Features
    ['creator_features'] = 'Características',
    ['creator_enable_tuneshop'] = 'Habilitar Taller de Tuning',
    ['creator_enable_carlift'] = 'Habilitar Elevador',
    ['creator_enable_stash'] = 'Habilitar Almacén',
    ['creator_enable_engine_swap'] = 'Habilitar Intercambio de Motor',
    
    -- Blip Configuration
    ['creator_blip_config'] = 'Configuración de Blip en Mapa',
    ['creator_blip_enabled'] = 'Mostrar en Mapa',
    ['creator_blip_sprite'] = 'Icono del Blip',
    ['creator_blip_color'] = 'Color del Blip',
    ['creator_blip_scale'] = 'Tamaño del Blip',
    
    -- Actions
    ['creator_save'] = 'Guardar Taller',
    ['creator_delete'] = 'Eliminar Taller',
    ['creator_cancel'] = 'Cancelar',
    ['creator_confirm_delete'] = '¿Estás seguro de que quieres eliminar este taller? Esta acción no se puede deshacer.',
    
    -- ========================================================================
    -- TUNESHOP
    -- ========================================================================
    ['tuneshop_title'] = 'Taller de Tuning',
    ['tuneshop_performance'] = 'Rendimiento',
    ['tuneshop_cosmetic'] = 'Cosmético',
    ['tuneshop_wheels'] = 'Ruedas',
    ['tuneshop_lighting'] = 'Iluminación',
    ['tuneshop_select_category'] = 'Selecciona una categoría',
    ['tuneshop_add_to_cart'] = 'Agregar al Carrito',
    ['tuneshop_cart'] = 'Carrito',
    ['tuneshop_total'] = 'Total',
    ['tuneshop_checkout'] = 'Pagar',
    ['tuneshop_clear_cart'] = 'Vaciar Carrito',
    ['tuneshop_level'] = 'Nivel',
    ['tuneshop_installed'] = 'Instalado',
    
    -- ========================================================================
    -- TABLET
    -- ========================================================================
    ['tablet_home'] = 'Inicio',
    ['tablet_dashboard'] = 'Panel',
    ['tablet_orders'] = 'Órdenes',
    ['tablet_employees'] = 'Empleados',
    ['tablet_management'] = 'Gestión',
    ['tablet_settings'] = 'Configuración',
    ['tablet_logout'] = 'Salir',
    
    -- Dashboard
    ['tablet_total_orders'] = 'Total de Órdenes',
    ['tablet_completed_orders'] = 'Órdenes Completadas',
    ['tablet_total_employees'] = 'Total de Empleados',
    ['tablet_recent_orders'] = 'Órdenes Recientes',
    ['tablet_no_recent_orders'] = 'Sin Órdenes Recientes',
    ['tablet_orders_will_appear'] = 'Las órdenes aparecerán aquí cuando se realicen',
    
    -- Orders
    ['tablet_order_details'] = 'Detalles de la Orden',
    ['tablet_install_modifications'] = 'Instalar Modificaciones',
    ['tablet_customer'] = 'Cliente',
    ['tablet_vehicle'] = 'Vehículo',
    ['tablet_plate'] = 'Placa',
    ['tablet_modifications'] = 'Modificaciones',
    ['tablet_total_cost'] = 'Costo Total',
    ['tablet_status'] = 'Estado',
    ['tablet_status_pending'] = 'Pendiente',
    ['tablet_status_installing'] = 'Instalando',
    ['tablet_status_completed'] = 'Completado',
    ['tablet_status_failed'] = 'Fallido',
    ['tablet_no_active_orders'] = 'Sin Órdenes Activas',
    ['tablet_no_pending_orders'] = 'No hay órdenes de trabajo pendientes en este momento. Las órdenes aparecerán aquí cuando los clientes compren modificaciones.',
    
    -- Employees
    ['tablet_employee_management'] = 'Gestión de Empleados',
    ['tablet_hire_employee'] = 'Contratar Empleado',
    ['tablet_fire_employee'] = 'Despedir Empleado',
    ['tablet_employee_name'] = 'Nombre',
    ['tablet_employee_grade'] = 'Grado',
    ['tablet_employee_hired'] = 'Contratado',
    ['tablet_no_employees'] = 'Sin Empleados',
    ['tablet_no_employees_desc'] = 'Este taller no tiene empleados. Puedes contratar nuevos empleados usando el botón de arriba.',
    ['tablet_enter_server_id'] = 'Introduce ID del Servidor',
    ['tablet_confirm_fire'] = '¿Estás seguro de que quieres despedir a este empleado?',
    
    -- ========================================================================
    -- NOTIFICACIONES
    -- ========================================================================
    ['success_shop_created'] = 'Taller creado exitosamente',
    ['success_shop_updated'] = 'Taller actualizado exitosamente',
    ['success_shop_deleted'] = 'Taller eliminado exitosamente',
    ['success_order_created'] = 'Orden creada exitosamente',
    ['success_order_completed'] = 'Orden completada exitosamente',
    ['success_employee_hired'] = 'Empleado contratado exitosamente',
    ['success_employee_fired'] = 'Empleado despedido exitosamente',
    ['success_modifications_installed'] = 'Modificaciones instaladas exitosamente',
    
    ['error_insufficient_funds'] = 'Fondos insuficientes',
    ['error_no_vehicle'] = 'No se encontró vehículo',
    ['error_vehicle_too_far'] = 'El vehículo está muy lejos',
    ['error_not_authorized'] = 'No estás autorizado',
    ['error_insufficient_grade'] = 'Grado de trabajo insuficiente',
    ['error_boss_grade_required'] = 'Se requiere rango de jefe para acceder a esta función',
    ['error_shop_not_found'] = 'Taller no encontrado',
    ['error_order_not_found'] = 'Orden no encontrada',
    ['error_player_not_found'] = 'Jugador no encontrado o no está en línea',
    ['error_already_employee'] = 'El jugador ya es empleado',
    ['error_cannot_fire_self'] = 'No puedes despedirte a ti mismo',
    
    -- ========================================================================
    -- INTERACCIONES
    -- ========================================================================
    ['interact_duty'] = 'Cambiar Servicio',
    ['interact_stash'] = 'Abrir Almacén',
    ['interact_bossmenu'] = 'Menú Jefe',
    ['interact_tuneshop'] = 'Abrir Taller de Tuning',
    ['interact_carlift'] = 'Usar Elevador',
    ['interact_tablet'] = 'Abrir Tablet',
    ['interact_raise_vehicle'] = 'Elevar Vehículo',
    ['interact_lower_vehicle'] = 'Bajar Vehículo',
    
    -- ========================================================================
    -- BARRAS DE PROGRESO
    -- ========================================================================
    ['progress_installing'] = 'Instalando modificaciones...',
    ['progress_repairing'] = 'Reparando vehículo...',
    ['progress_washing'] = 'Lavando vehículo...',
}