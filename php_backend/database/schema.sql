-- ============================================================
--  Smart Real Estate Platform "عقاري"
--  MySQL Database Schema — Complete & Production-Ready
--  Engine: InnoDB | Charset: utf8mb4 | Collation: utf8mb4_unicode_ci
-- ============================================================

CREATE DATABASE IF NOT EXISTS smart_real_estate
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE smart_real_estate;

-- ============================================================
-- 1. users — جدول المستخدمين (جميع الأدوار)
-- ============================================================
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
    fcm_token     VARCHAR(500)     NULL COMMENT 'Firebase Cloud Messaging token for push notifications',
    last_login_at TIMESTAMP        NULL,
    created_at    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_email (email),
    INDEX idx_role (role),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 2. agencies — جدول بيانات الوكالات العقارية
-- ============================================================
CREATE TABLE IF NOT EXISTS agencies (
    id              INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED   NOT NULL,
    agency_name     VARCHAR(255)   NOT NULL,
    license_number  VARCHAR(100)   NULL,
    description     TEXT           NULL,
    logo            VARCHAR(500)   NULL,
    website         VARCHAR(255)   NULL,
    address         VARCHAR(500)   NULL,
    city            VARCHAR(100)   NULL,
    rating_avg      DECIMAL(3,2)   NOT NULL DEFAULT 0.00,
    total_reviews   INT UNSIGNED   NOT NULL DEFAULT 0,
    is_verified     TINYINT(1)     NOT NULL DEFAULT 0,
    created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_agency_user (user_id),
    INDEX idx_agency_city (city),
    INDEX idx_agency_rating (rating_avg),
    FOREIGN KEY fk_agency_user (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. properties — جدول العقارات (الجدول المحوري)
-- ============================================================
CREATE TABLE IF NOT EXISTS properties (
    id               INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    owner_id         INT UNSIGNED     NOT NULL,
    title            VARCHAR(255)     NOT NULL,
    description      TEXT             NULL,
    price            DECIMAL(15,2)    NOT NULL,
    listing_type     ENUM('sale','rent') NOT NULL DEFAULT 'sale',
    property_type    ENUM('villa','apartment','commercial','land','office') NOT NULL DEFAULT 'apartment',
    location         VARCHAR(255)     NULL,
    city             VARCHAR(100)     NULL,
    district         VARCHAR(100)     NULL,
    status           ENUM('available','sold','rented','pending','rejected') NOT NULL DEFAULT 'available',
    bedrooms         INT UNSIGNED     NOT NULL DEFAULT 0,
    bathrooms        INT UNSIGNED     NOT NULL DEFAULT 0,
    area             DECIMAL(10,2)    NULL COMMENT 'Area in square meters',
    floor            INT              NULL,
    total_floors     INT              NULL,
    year_built       YEAR             NULL,
    is_furnished     TINYINT(1)       NOT NULL DEFAULT 0,
    latitude         DECIMAL(10,7)    NULL,
    longitude        DECIMAL(10,7)    NULL,
    virtual_tour_url VARCHAR(500)     NULL,
    views_count      INT UNSIGNED     NOT NULL DEFAULT 0,
    is_featured      TINYINT(1)       NOT NULL DEFAULT 0,
    admin_approved   TINYINT(1)       NOT NULL DEFAULT 1,
    created_at       TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY fk_property_owner (owner_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_property_type (property_type),
    INDEX idx_listing_type (listing_type),
    INDEX idx_status (status),
    INDEX idx_prop_city (city),
    INDEX idx_price (price),
    INDEX idx_bedrooms (bedrooms),
    INDEX idx_featured (is_featured),
    INDEX idx_owner (owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. property_images — جدول صور العقارات
-- ============================================================
CREATE TABLE IF NOT EXISTS property_images (
    id          INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    property_id INT UNSIGNED   NOT NULL,
    image_url   VARCHAR(500)   NOT NULL,
    is_primary  TINYINT(1)     NOT NULL DEFAULT 0,
    sort_order  INT UNSIGNED   NOT NULL DEFAULT 0,
    created_at  TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY fk_image_property (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    INDEX idx_property_primary (property_id, is_primary)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. property_features — جدول مميزات ومرافق العقارات
-- ============================================================
CREATE TABLE IF NOT EXISTS property_features (
    id           INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    property_id  INT UNSIGNED   NOT NULL,
    feature_name VARCHAR(100)   NOT NULL COMMENT 'e.g. Swimming Pool, Gym, Parking, Elevator, Security',
    FOREIGN KEY fk_feature_property (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    INDEX idx_property_features (property_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. favorites — جدول المفضلة
-- ============================================================
CREATE TABLE IF NOT EXISTS favorites (
    id          INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED   NOT NULL,
    property_id INT UNSIGNED   NOT NULL,
    created_at  TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_fav (user_id, property_id),
    FOREIGN KEY fk_fav_user     (user_id)     REFERENCES users(id)      ON DELETE CASCADE,
    FOREIGN KEY fk_fav_property (property_id) REFERENCES properties(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. reviews — جدول التقييمات والمراجعات
-- ============================================================
CREATE TABLE IF NOT EXISTS reviews (
    id          INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED     NOT NULL,
    property_id INT UNSIGNED     NULL,
    agency_id   INT UNSIGNED     NULL,
    rating      TINYINT UNSIGNED NOT NULL,
    comment     TEXT             NULL,
    created_at  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_rating        CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT chk_review_target CHECK (property_id IS NOT NULL OR agency_id IS NOT NULL),
    FOREIGN KEY fk_review_user     (user_id)     REFERENCES users(id)      ON DELETE CASCADE,
    FOREIGN KEY fk_review_property (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY fk_review_agency   (agency_id)   REFERENCES agencies(id)   ON DELETE CASCADE,
    INDEX idx_property_rating (property_id, rating),
    INDEX idx_agency_rating   (agency_id,   rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. conversations — جدول جلسات المحادثات (Chat Sessions)
-- ============================================================
CREATE TABLE IF NOT EXISTS conversations (
    id          INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    property_id INT UNSIGNED   NULL,
    created_at  TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY fk_conv_property (property_id) REFERENCES properties(id) ON DELETE SET NULL,
    INDEX idx_conv_property (property_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 9. conversation_participants — جدول أطراف المحادثة
-- ============================================================
CREATE TABLE IF NOT EXISTS conversation_participants (
    conversation_id INT UNSIGNED   NOT NULL,
    user_id         INT UNSIGNED   NOT NULL,
    last_read_at    TIMESTAMP      NULL,
    PRIMARY KEY (conversation_id, user_id),
    FOREIGN KEY fk_cp_conv (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY fk_cp_user (user_id)         REFERENCES users(id)         ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 10. messages — جدول رسائل المحادثات
-- ============================================================
CREATE TABLE IF NOT EXISTS messages (
    id              INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT UNSIGNED   NOT NULL,
    sender_id       INT UNSIGNED   NOT NULL,
    message         TEXT           NOT NULL,
    is_read         TINYINT(1)     NOT NULL DEFAULT 0,
    created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY fk_msg_conv   (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY fk_msg_sender (sender_id)       REFERENCES users(id)         ON DELETE CASCADE,
    INDEX idx_conv_msg (conversation_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. notifications — جدول الإشعارات
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
    id           INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    user_id      INT UNSIGNED   NOT NULL,
    title        VARCHAR(255)   NOT NULL,
    body         TEXT           NULL,
    type         ENUM('message','property','review','appointment','system','promotion') NOT NULL DEFAULT 'system',
    reference_id INT UNSIGNED   NULL COMMENT 'ID of the related entity (property_id, message_id, etc.)',
    is_read      TINYINT(1)     NOT NULL DEFAULT 0,
    created_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY fk_notif_user (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_read (user_id, is_read),
    INDEX idx_user_type (user_id, type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. appointments — جدول مواعيد معاينة العقارات
-- ============================================================
CREATE TABLE IF NOT EXISTS appointments (
    id               INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    property_id      INT UNSIGNED   NOT NULL,
    user_id          INT UNSIGNED   NOT NULL COMMENT 'المستخدم الطالب للمعاينة',
    owner_id         INT UNSIGNED   NOT NULL COMMENT 'مالك العقار',
    appointment_date DATE           NOT NULL,
    appointment_time TIME           NOT NULL,
    status           ENUM('pending','confirmed','cancelled','completed') NOT NULL DEFAULT 'pending',
    notes            TEXT           NULL,
    created_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY fk_apt_property (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY fk_apt_user     (user_id)     REFERENCES users(id)      ON DELETE CASCADE,
    FOREIGN KEY fk_apt_owner    (owner_id)    REFERENCES users(id)      ON DELETE CASCADE,
    INDEX idx_apt_status   (status),
    INDEX idx_apt_property (property_id),
    INDEX idx_apt_user     (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 13. user_preferences — تفضيلات المستخدم (لنظام التوصيات AI)
-- ============================================================
CREATE TABLE IF NOT EXISTS user_preferences (
    id                INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    user_id           INT UNSIGNED   NOT NULL,
    preferred_types   VARCHAR(255)   NULL COMMENT 'JSON array e.g. ["villa","apartment"]',
    preferred_listing ENUM('sale','rent','both') NOT NULL DEFAULT 'both',
    min_price         DECIMAL(15,2)  NULL,
    max_price         DECIMAL(15,2)  NULL,
    min_area          DECIMAL(10,2)  NULL,
    max_area          DECIMAL(10,2)  NULL,
    min_bedrooms      INT UNSIGNED   NULL,
    preferred_cities  VARCHAR(500)   NULL COMMENT 'JSON array e.g. ["Riyadh","Jeddah"]',
    updated_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_pref_user (user_id),
    FOREIGN KEY fk_pref_user (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 14. property_views — تتبع مشاهدات العقارات (للتحليلات والـ AI)
-- ============================================================
CREATE TABLE IF NOT EXISTS property_views (
    id          INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    property_id INT UNSIGNED   NOT NULL,
    user_id     INT UNSIGNED   NULL COMMENT 'NULL = زائر غير مسجل',
    viewed_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY fk_pv_property (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY fk_pv_user     (user_id)     REFERENCES users(id)      ON DELETE SET NULL,
    INDEX idx_user_views     (user_id),
    INDEX idx_property_views (property_id),
    INDEX idx_viewed_at      (viewed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 15. search_history — سجل بحث المستخدمين (لنظام التوصيات AI)
-- ============================================================
CREATE TABLE IF NOT EXISTS search_history (
    id            INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    user_id       INT UNSIGNED   NOT NULL,
    search_query  VARCHAR(500)   NULL,
    filters       JSON           NULL COMMENT 'Filter parameters as JSON object',
    results_count INT UNSIGNED   NOT NULL DEFAULT 0,
    searched_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY fk_sh_user (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_search (user_id),
    INDEX idx_search_date (searched_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 16. price_alerts — تنبيهات تغيير السعر
-- ============================================================
CREATE TABLE IF NOT EXISTS price_alerts (
    id           INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    user_id      INT UNSIGNED   NOT NULL,
    property_id  INT UNSIGNED   NOT NULL,
    alert_price  DECIMAL(15,2)  NULL    COMMENT 'NULL = أشعرني عند أي تغيير',
    direction    ENUM('any','drop','rise') NOT NULL DEFAULT 'any',
    is_active    TINYINT(1)     NOT NULL DEFAULT 1,
    triggered_at TIMESTAMP      NULL    COMMENT 'وقت آخر إشعار تم إرساله',
    created_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_alert (user_id, property_id),
    FOREIGN KEY fk_pa_user     (user_id)     REFERENCES users(id)      ON DELETE CASCADE,
    FOREIGN KEY fk_pa_property (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    INDEX idx_pa_active (is_active),
    INDEX idx_pa_property (property_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 17. market_stats — إحصائيات السوق العقاري (لبطاقة اتجاهات السوق)
-- ============================================================
CREATE TABLE IF NOT EXISTS market_stats (
    id                  INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    city                VARCHAR(100)    NOT NULL,
    property_type       ENUM('villa','apartment','commercial','land','office','all') NOT NULL DEFAULT 'all',
    listing_type        ENUM('sale','rent','all') NOT NULL DEFAULT 'all',
    avg_price_per_sqm   DECIMAL(12,2)   NOT NULL DEFAULT 0.00,
    price_change_pct    DECIMAL(6,2)    NOT NULL DEFAULT 0.00 COMMENT 'Year-over-year %',
    active_listings     INT UNSIGNED    NOT NULL DEFAULT 0,
    avg_days_on_market  INT UNSIGNED    NULL     COMMENT 'متوسط أيام الإدراج',
    total_transactions  INT UNSIGNED    NOT NULL DEFAULT 0,
    recorded_month      DATE            NOT NULL COMMENT 'أول يوم من الشهر المقيس',
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_market_stat (city, property_type, listing_type, recorded_month),
    INDEX idx_ms_city        (city),
    INDEX idx_ms_month       (recorded_month),
    INDEX idx_ms_type        (property_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 18. contracts — جدول العقود العقارية
-- ============================================================
CREATE TABLE IF NOT EXISTS contracts (
    id               INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    contract_number  VARCHAR(50)      NOT NULL,
    property_id      INT UNSIGNED     NOT NULL,
    buyer_id         INT UNSIGNED     NOT NULL  COMMENT 'المستأجر أو المشتري',
    seller_id        INT UNSIGNED     NOT NULL  COMMENT 'المالك أو البائع',
    type             ENUM('sale','rent','agency') NOT NULL DEFAULT 'sale',
    status           ENUM('pending','under_review','signed','expired','cancelled') NOT NULL DEFAULT 'pending',
    amount           DECIMAL(15,2)    NOT NULL,
    start_date       DATE             NULL,
    end_date         DATE             NULL,
    expiry_date      DATE             NULL,
    notes            TEXT             NULL,
    buyer_signed     TINYINT(1)       NOT NULL DEFAULT 0,
    seller_signed    TINYINT(1)       NOT NULL DEFAULT 0,
    signed_at        TIMESTAMP        NULL,
    created_at       TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_contract_number (contract_number),
    FOREIGN KEY fk_con_property (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY fk_con_buyer    (buyer_id)    REFERENCES users(id)      ON DELETE CASCADE,
    FOREIGN KEY fk_con_seller   (seller_id)   REFERENCES users(id)      ON DELETE CASCADE,
    INDEX idx_con_status   (status),
    INDEX idx_con_buyer    (buyer_id),
    INDEX idx_con_seller   (seller_id),
    INDEX idx_con_property (property_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 19. contract_signatures — التوقيعات الإلكترونية للعقود
-- ============================================================
CREATE TABLE IF NOT EXISTS contract_signatures (
    id            INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    contract_id   INT UNSIGNED   NOT NULL,
    user_id       INT UNSIGNED   NOT NULL,
    role          ENUM('buyer','seller') NOT NULL,
    signature_b64 MEDIUMTEXT     NOT NULL COMMENT 'Base64-encoded PNG of drawn signature',
    ip_address    VARCHAR(45)    NULL     COMMENT 'IPv4 or IPv6 for audit trail',
    user_agent    VARCHAR(500)   NULL,
    signed_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_sig (contract_id, user_id),
    FOREIGN KEY fk_sig_contract (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    FOREIGN KEY fk_sig_user     (user_id)     REFERENCES users(id)     ON DELETE CASCADE,
    INDEX idx_sig_contract (contract_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 20. payments — جدول المدفوعات والمعاملات المالية
-- ============================================================
CREATE TABLE IF NOT EXISTS payments (
    id              INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    transaction_id  VARCHAR(100)     NOT NULL  COMMENT 'معرف فريد للمعاملة',
    contract_id     INT UNSIGNED     NULL,
    payer_id        INT UNSIGNED     NOT NULL,
    payee_id        INT UNSIGNED     NOT NULL,
    property_id     INT UNSIGNED     NULL,
    amount          DECIMAL(15,2)    NOT NULL,
    currency        VARCHAR(10)      NOT NULL DEFAULT 'SAR',
    method          ENUM('credit_card','debit_card','bank_transfer','stc_pay','apple_pay','qr_code') NOT NULL DEFAULT 'credit_card',
    status          ENUM('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
    qr_payload      TEXT             NULL  COMMENT 'JSON data encoded in the receipt QR code',
    notes           TEXT             NULL,
    paid_at         TIMESTAMP        NULL,
    created_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_transaction (transaction_id),
    FOREIGN KEY fk_pay_contract (contract_id)  REFERENCES contracts(id)  ON DELETE SET NULL,
    FOREIGN KEY fk_pay_payer    (payer_id)      REFERENCES users(id)      ON DELETE CASCADE,
    FOREIGN KEY fk_pay_payee    (payee_id)      REFERENCES users(id)      ON DELETE CASCADE,
    FOREIGN KEY fk_pay_property (property_id)   REFERENCES properties(id) ON DELETE SET NULL,
    INDEX idx_pay_status     (status),
    INDEX idx_pay_payer      (payer_id),
    INDEX idx_pay_payee      (payee_id),
    INDEX idx_pay_contract   (contract_id),
    INDEX idx_pay_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 21. payment_verifications — التحقق من المدفوعات عبر QR Code
-- ============================================================
CREATE TABLE IF NOT EXISTS payment_verifications (
    id             INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    payment_id     INT UNSIGNED   NOT NULL,
    verification_code VARCHAR(64) NOT NULL  COMMENT 'SHA-256 hash used in QR',
    scanned_at     TIMESTAMP      NULL,
    scanner_ip     VARCHAR(45)    NULL,
    scan_count     INT UNSIGNED   NOT NULL DEFAULT 0,
    is_valid       TINYINT(1)     NOT NULL DEFAULT 1,
    created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_verification_code (verification_code),
    FOREIGN KEY fk_pv_payment (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
    INDEX idx_pv_payment (payment_id),
    INDEX idx_pv_code    (verification_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
