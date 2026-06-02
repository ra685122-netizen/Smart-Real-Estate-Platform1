CREATE DATABASE IF NOT EXISTS smart_real_estate CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smart_real_estate;

CREATE TABLE IF NOT EXISTS users (
    id            INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(255)     NOT NULL,
    email         VARCHAR(255)     NOT NULL,
    password_hash VARCHAR(255)     NOT NULL,
    role          ENUM('tenant','buyer','seller','owner','agency','admin') NOT NULL DEFAULT 'buyer',
    phone         VARCHAR(20)      NULL,
    avatar        VARCHAR(500)     NULL,
    bio           TEXT             NULL,
    is_verified   TINYINT(1)       NOT NULL DEFAULT 0,
    is_active     TINYINT(1)       NOT NULL DEFAULT 1,
    fcm_token     VARCHAR(500)     NULL,
    last_login_at TIMESTAMP        NULL,
    created_at    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_email (email),
    INDEX idx_role (role),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO users (name, email, password_hash, role, phone, is_verified, is_active) VALUES
('Admin User',       'admin@aqari.com',   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin',  '+966500000001', 1, 1),
('Ahmed Al-Malki',   'ahmed@aqari.com',   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'owner',  '+966500000002', 1, 1),
('Sara Al-Zahrani',  'sara@aqari.com',    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'buyer',  '+966500000003', 1, 1),
('Fatima Al-Otaibi', 'fatima@aqari.com',  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'tenant', '+966500000005', 1, 1),
('Mohammed Seller',  'seller@aqari.com',  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'seller', '+966500000006', 1, 1)
ON DUPLICATE KEY UPDATE
    password_hash = VALUES(password_hash),
    is_verified   = 1,
    is_active     = 1;

SELECT id, name, email, role FROM users;
