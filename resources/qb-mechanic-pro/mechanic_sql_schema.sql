-- ============================================================================
-- QB-MECHANIC-PRO - Database Schema
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TABLA: mechanic_shops
-- Almacena configuración completa de cada taller
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `mechanic_shops` (
    `id` VARCHAR(50) NOT NULL PRIMARY KEY,
    `shop_name` VARCHAR(100) NOT NULL,
    `ownership_type` ENUM('public', 'job') DEFAULT 'public',
    `job_name` VARCHAR(50) NULL,
    `minimum_grade` INT DEFAULT 0,
    `boss_grade` INT DEFAULT 3,
    `owner_license` VARCHAR(50) NULL,
    `config_data` LONGTEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_job_name` (`job_name`),
    INDEX `idx_owner` (`owner_license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- TABLA: mechanic_employees
-- Gestión de empleados por taller
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `mechanic_employees` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `shop_id` VARCHAR(50) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `employee_name` VARCHAR(100) NOT NULL,
    `job_grade` INT DEFAULT 0,
    `hired_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY `unique_shop_employee` (`shop_id`, `citizenid`),
    FOREIGN KEY (`shop_id`) REFERENCES `mechanic_shops`(`id`) ON DELETE CASCADE,
    INDEX `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- TABLA: mechanic_orders
-- Sistema de órdenes de trabajo
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `mechanic_orders` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `shop_id` VARCHAR(50) NOT NULL,
    `customer_citizenid` VARCHAR(50) NOT NULL,
    `customer_name` VARCHAR(100) NOT NULL,
    `vehicle_plate` VARCHAR(10) NOT NULL,
    `vehicle_model` VARCHAR(50) NOT NULL,
    `modifications` LONGTEXT NOT NULL,
    `total_cost` INT NOT NULL DEFAULT 0,
    `status` ENUM('pending', 'installing', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
    `mechanic_citizenid` VARCHAR(50) NULL,
    `mechanic_name` VARCHAR(100) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `installed_at` TIMESTAMP NULL,
    `completed_at` TIMESTAMP NULL,
    
    FOREIGN KEY (`shop_id`) REFERENCES `mechanic_shops`(`id`) ON DELETE CASCADE,
    INDEX `idx_status` (`status`),
    INDEX `idx_customer` (`customer_citizenid`),
    INDEX `idx_vehicle` (`vehicle_plate`),
    INDEX `idx_shop_status` (`shop_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- TABLA: mechanic_transactions
-- Historial de transacciones financieras
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `mechanic_transactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `shop_id` VARCHAR(50) NOT NULL,
    `transaction_type` ENUM('order_payment', 'commission', 'expense', 'withdrawal', 'deposit') NOT NULL,
    `amount` INT NOT NULL,
    `description` VARCHAR(255) NULL,
    `employee_citizenid` VARCHAR(50) NULL,
    `order_id` INT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`shop_id`) REFERENCES `mechanic_shops`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`order_id`) REFERENCES `mechanic_orders`(`id`) ON DELETE SET NULL,
    INDEX `idx_shop_date` (`shop_id`, `created_at`),
    INDEX `idx_type` (`transaction_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- TABLA: mechanic_vehicle_tracking (OPCIONAL - Sistema de seguimiento)
-- Tracking de vehículos que han pasado por talleres
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `mechanic_vehicle_tracking` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `vehicle_plate` VARCHAR(10) NOT NULL,
    `shop_id` VARCHAR(50) NOT NULL,
    `service_type` VARCHAR(50) NOT NULL,
    `cost` INT NOT NULL,
    `mileage` DECIMAL(12,2) DEFAULT 0,
    `mechanic_citizenid` VARCHAR(50) NULL,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_plate` (`vehicle_plate`),
    INDEX `idx_shop` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- DATOS DE EJEMPLO (Comentar después de primera instalación)
-- ============================================================================

-- Taller de ejemplo: Benny's Original Motor Works
INSERT INTO `mechanic_shops` (`id`, `shop_name`, `ownership_type`, `job_name`, `minimum_grade`, `boss_grade`, `config_data`) VALUES
('bennys_lsia', "Benny's Original Motor Works", 'job', 'mechanic', 0, 3, 
'{"blip":{"enabled":true,"sprite":446,"color":5,"label":"Benny\'s Motor Works"},"locations":{"duty":{"x":-211.45,"y":-1324.68,"z":30.89},"stash":{"x":-218.19,"y":-1328.20,"z":30.89},"bossmenu":{"x":-223.04,"y":-1318.61,"z":30.89},"tuneshop":[{"x":-205.83,"y":-1312.07,"z":31.28,"heading":270.0}],"carlift":[{"x":-198.50,"y":-1318.30,"z":31.09,"heading":270.0}]},"features":{"enable_tuneshop":true,"enable_carlift":true,"enable_engine_swap":false,"enable_stash":true}}');

-- ============================================================================
-- VERIFICACIÓN DE INSTALACIÓN
-- ============================================================================
SELECT 
    'mechanic_shops' as tabla, COUNT(*) as registros 
FROM mechanic_shops
UNION ALL
SELECT 'mechanic_employees', COUNT(*) FROM mechanic_employees
UNION ALL
SELECT 'mechanic_orders', COUNT(*) FROM mechanic_orders
UNION ALL
SELECT 'mechanic_transactions', COUNT(*) FROM mechanic_transactions;
