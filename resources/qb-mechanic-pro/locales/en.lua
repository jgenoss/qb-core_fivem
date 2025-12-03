-- ============================================================================
-- QB-MECHANIC-PRO - English Translations
-- ============================================================================

Locale = Locale or {}
Locale['en'] = {
    -- ========================================================================
    -- GENERAL
    -- ========================================================================
    ['shop_name'] = 'Mechanic Shop',
    ['blip_name'] = 'Mechanic',
    ['enter_zone'] = 'Press ~INPUT_CONTEXT~ to open menu',
    ['close_ui'] = 'Press ~INPUT_CANCEL~ to close',
    
    -- ========================================================================
    -- CREATOR UI
    -- ========================================================================
    ['creator_title'] = 'Mechanic Shop Creator',
    ['creator_statistics'] = 'Statistics',
    ['creator_mechanics'] = 'Mechanics',
    ['creator_create_new'] = 'Create New',
    
    -- Basic Information
    ['creator_basic_info'] = 'Basic Information',
    ['creator_shop_name'] = 'Shop Name',
    ['creator_shop_name_placeholder'] = "Benny's Original Motor Works",
    ['creator_ownership_type'] = 'Ownership Type',
    ['creator_ownership_public'] = 'Public',
    ['creator_ownership_job'] = 'Job Restricted',
    ['creator_job_name'] = 'Job Name',
    ['creator_job_name_placeholder'] = 'mechanic',
    ['creator_minimum_grade'] = 'Minimum Grade',
    ['creator_boss_grade'] = 'Boss Grade (Management Access)',
    ['creator_boss_grade_desc'] = 'Grade required to access Management and Settings in the tablet',
    
    -- Locations
    ['creator_locations'] = 'Locations',
    ['creator_duty_location'] = 'Duty Location',
    ['creator_stash_location'] = 'Stash Location',
    ['creator_bossmenu_location'] = 'Boss Menu Location',
    ['creator_tuneshop_locations'] = 'Tuneshop Locations',
    ['creator_carlift_locations'] = 'Carlift Locations',
    ['creator_add_location'] = 'Add Location',
    ['creator_set_location'] = 'Set Current Position',
    ['creator_teleport'] = 'Teleport',
    ['creator_remove'] = 'Remove',
    
    -- Features
    ['creator_features'] = 'Features',
    ['creator_enable_tuneshop'] = 'Enable Tuneshop',
    ['creator_enable_carlift'] = 'Enable Carlift',
    ['creator_enable_stash'] = 'Enable Stash',
    ['creator_enable_engine_swap'] = 'Enable Engine Swap',
    
    -- Blip Configuration
    ['creator_blip_config'] = 'Map Blip Configuration',
    ['creator_blip_enabled'] = 'Show on Map',
    ['creator_blip_sprite'] = 'Blip Icon',
    ['creator_blip_color'] = 'Blip Color',
    ['creator_blip_scale'] = 'Blip Size',
    
    -- Actions
    ['creator_save'] = 'Save Shop',
    ['creator_delete'] = 'Delete Shop',
    ['creator_cancel'] = 'Cancel',
    ['creator_confirm_delete'] = 'Are you sure you want to delete this shop? This action cannot be undone.',
    
    -- ========================================================================
    -- TUNESHOP
    -- ========================================================================
    ['tuneshop_title'] = 'Tuning Shop',
    ['tuneshop_performance'] = 'Performance',
    ['tuneshop_cosmetic'] = 'Cosmetic',
    ['tuneshop_wheels'] = 'Wheels',
    ['tuneshop_lighting'] = 'Lighting',
    ['tuneshop_select_category'] = 'Select a category',
    ['tuneshop_add_to_cart'] = 'Add to Cart',
    ['tuneshop_cart'] = 'Cart',
    ['tuneshop_total'] = 'Total',
    ['tuneshop_checkout'] = 'Checkout',
    ['tuneshop_clear_cart'] = 'Clear Cart',
    ['tuneshop_level'] = 'Level',
    ['tuneshop_installed'] = 'Installed',
    
    -- ========================================================================
    -- TABLET
    -- ========================================================================
    ['tablet_home'] = 'Home',
    ['tablet_dashboard'] = 'Dashboard',
    ['tablet_orders'] = 'Orders',
    ['tablet_employees'] = 'Employees',
    ['tablet_management'] = 'Management',
    ['tablet_settings'] = 'Settings',
    ['tablet_logout'] = 'Logout',
    
    -- Dashboard
    ['tablet_total_orders'] = 'Total Orders',
    ['tablet_completed_orders'] = 'Completed Orders',
    ['tablet_total_employees'] = 'Total Employees',
    ['tablet_recent_orders'] = 'Recent Orders',
    ['tablet_no_recent_orders'] = 'No Recent Orders',
    ['tablet_orders_will_appear'] = 'Orders will appear here when placed',
    
    -- Orders
    ['tablet_order_details'] = 'Order Details',
    ['tablet_install_modifications'] = 'Install Modifications',
    ['tablet_customer'] = 'Customer',
    ['tablet_vehicle'] = 'Vehicle',
    ['tablet_plate'] = 'Plate',
    ['tablet_modifications'] = 'Modifications',
    ['tablet_total_cost'] = 'Total Cost',
    ['tablet_status'] = 'Status',
    ['tablet_status_pending'] = 'Pending',
    ['tablet_status_installing'] = 'Installing',
    ['tablet_status_completed'] = 'Completed',
    ['tablet_status_failed'] = 'Failed',
    ['tablet_no_active_orders'] = 'No Active Orders',
    ['tablet_no_pending_orders'] = 'No pending work orders at this time. Orders will appear here when customers purchase modifications.',
    
    -- Employees
    ['tablet_employee_management'] = 'Employee Management',
    ['tablet_hire_employee'] = 'Hire Employee',
    ['tablet_fire_employee'] = 'Fire Employee',
    ['tablet_employee_name'] = 'Name',
    ['tablet_employee_grade'] = 'Grade',
    ['tablet_employee_hired'] = 'Hired',
    ['tablet_no_employees'] = 'No Employees',
    ['tablet_no_employees_desc'] = 'This shop has no employees. You can hire new employees using the button above.',
    ['tablet_enter_server_id'] = 'Enter Server ID',
    ['tablet_confirm_fire'] = 'Are you sure you want to fire this employee?',
    
    -- ========================================================================
    -- NOTIFICATIONS
    -- ========================================================================
    ['success_shop_created'] = 'Shop created successfully',
    ['success_shop_updated'] = 'Shop updated successfully',
    ['success_shop_deleted'] = 'Shop deleted successfully',
    ['success_order_created'] = 'Order created successfully',
    ['success_order_completed'] = 'Order completed successfully',
    ['success_employee_hired'] = 'Employee hired successfully',
    ['success_employee_fired'] = 'Employee fired successfully',
    ['success_modifications_installed'] = 'Modifications installed successfully',
    
    ['error_insufficient_funds'] = 'Insufficient funds',
    ['error_no_vehicle'] = 'No vehicle found',
    ['error_vehicle_too_far'] = 'Vehicle is too far away',
    ['error_not_authorized'] = 'You are not authorized',
    ['error_insufficient_grade'] = 'Insufficient job grade',
    ['error_boss_grade_required'] = 'Boss grade required to access this feature',
    ['error_shop_not_found'] = 'Shop not found',
    ['error_order_not_found'] = 'Order not found',
    ['error_player_not_found'] = 'Player not found or not online',
    ['error_already_employee'] = 'Player is already an employee',
    ['error_cannot_fire_self'] = 'You cannot fire yourself',
    
    -- ========================================================================
    -- INTERACTIONS
    -- ========================================================================
    ['interact_duty'] = 'Toggle Duty',
    ['interact_stash'] = 'Open Stash',
    ['interact_bossmenu'] = 'Boss Menu',
    ['interact_tuneshop'] = 'Open Tuning Shop',
    ['interact_carlift'] = 'Use Carlift',
    ['interact_tablet'] = 'Open Tablet',
    ['interact_raise_vehicle'] = 'Raise Vehicle',
    ['interact_lower_vehicle'] = 'Lower Vehicle',
    
    -- ========================================================================
    -- PROGRESS BARS
    -- ========================================================================
    ['progress_installing'] = 'Installing modifications...',
    ['progress_repairing'] = 'Repairing vehicle...',
    ['progress_washing'] = 'Washing vehicle...',
}