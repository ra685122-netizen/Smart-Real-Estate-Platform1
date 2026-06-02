-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: May 11, 2026 at 12:39 AM
-- Server version: 5.7.24
-- PHP Version: 8.3.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `smart_real_estate`
--

-- --------------------------------------------------------

--
-- Table structure for table `agencies`
--

CREATE TABLE `agencies` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `agency_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `license_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `logo` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rating_avg` decimal(3,2) NOT NULL DEFAULT '0.00',
  `total_reviews` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

CREATE TABLE `appointments` (
  `id` int(10) UNSIGNED NOT NULL,
  `property_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL COMMENT 'المستخدم الطالب للمعاينة',
  `owner_id` int(10) UNSIGNED NOT NULL COMMENT 'مالك العقار',
  `appointment_date` date NOT NULL,
  `appointment_time` time NOT NULL,
  `status` enum('pending','confirmed','cancelled','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `contracts`
--

CREATE TABLE `contracts` (
  `id` int(10) UNSIGNED NOT NULL,
  `contract_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `property_id` int(10) UNSIGNED NOT NULL,
  `buyer_id` int(10) UNSIGNED NOT NULL COMMENT 'المستأجر أو المشتري',
  `seller_id` int(10) UNSIGNED NOT NULL COMMENT 'المالك أو البائع',
  `type` enum('sale','rent','agency') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'sale',
  `status` enum('pending','under_review','signed','expired','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `amount` decimal(15,2) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `buyer_signed` tinyint(1) NOT NULL DEFAULT '0',
  `seller_signed` tinyint(1) NOT NULL DEFAULT '0',
  `signed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `contract_signatures`
--

CREATE TABLE `contract_signatures` (
  `id` int(10) UNSIGNED NOT NULL,
  `contract_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `role` enum('buyer','seller') COLLATE utf8mb4_unicode_ci NOT NULL,
  `signature_b64` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Base64-encoded PNG of drawn signature',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IPv4 or IPv6 for audit trail',
  `user_agent` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `conversations`
--

CREATE TABLE `conversations` (
  `id` int(10) UNSIGNED NOT NULL,
  `property_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `conversations`
--

INSERT INTO `conversations` (`id`, `property_id`, `created_at`) VALUES
(1, NULL, '2026-04-11 11:08:18');

-- --------------------------------------------------------

--
-- Table structure for table `conversation_participants`
--

CREATE TABLE `conversation_participants` (
  `conversation_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `last_read_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `conversation_participants`
--

INSERT INTO `conversation_participants` (`conversation_id`, `user_id`, `last_read_at`) VALUES
(1, 1, NULL),
(1, 2, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `property_id` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `favorites`
--

INSERT INTO `favorites` (`id`, `user_id`, `property_id`, `created_at`) VALUES
(1, 1, 3, '2026-05-05 02:46:43');

-- --------------------------------------------------------

--
-- Table structure for table `market_stats`
--

CREATE TABLE `market_stats` (
  `id` int(10) UNSIGNED NOT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `property_type` enum('villa','apartment','commercial','land','office','all') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'all',
  `listing_type` enum('sale','rent','all') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'all',
  `avg_price_per_sqm` decimal(12,2) NOT NULL DEFAULT '0.00',
  `price_change_pct` decimal(6,2) NOT NULL DEFAULT '0.00' COMMENT 'Year-over-year %',
  `active_listings` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `avg_days_on_market` int(10) UNSIGNED DEFAULT NULL COMMENT 'متوسط أيام الإدراج',
  `total_transactions` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `recorded_month` date NOT NULL COMMENT 'أول يوم من الشهر المقيس',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int(10) UNSIGNED NOT NULL,
  `conversation_id` int(10) UNSIGNED NOT NULL,
  `sender_id` int(10) UNSIGNED NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `conversation_id`, `sender_id`, `message`, `is_read`, `created_at`) VALUES
(1, 1, 1, 'hi', 0, '2026-04-11 11:09:38'),
(2, 1, 1, 'Photo', 0, '2026-04-11 11:09:46'),
(3, 1, 1, 'هلا', 0, '2026-05-05 02:47:07'),
(4, 1, 1, 'كيفك', 0, '2026-05-05 02:47:11'),
(5, 1, 1, 'Photo', 0, '2026-05-05 02:47:45'),
(6, 1, 1, 'Photo', 0, '2026-05-05 02:47:56');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci,
  `type` enum('message','property','review','appointment','system','promotion') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'system',
  `reference_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'ID of the related entity (property_id, message_id, etc.)',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int(10) UNSIGNED NOT NULL,
  `transaction_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'معرف فريد للمعاملة',
  `contract_id` int(10) UNSIGNED DEFAULT NULL,
  `payer_id` int(10) UNSIGNED NOT NULL,
  `payee_id` int(10) UNSIGNED NOT NULL,
  `property_id` int(10) UNSIGNED DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SAR',
  `method` enum('credit_card','debit_card','bank_transfer','stc_pay','apple_pay','qr_code') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'credit_card',
  `status` enum('pending','completed','failed','refunded') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `qr_payload` text COLLATE utf8mb4_unicode_ci COMMENT 'JSON data encoded in the receipt QR code',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `paid_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payment_verifications`
--

CREATE TABLE `payment_verifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `payment_id` int(10) UNSIGNED NOT NULL,
  `verification_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'SHA-256 hash used in QR',
  `scanned_at` timestamp NULL DEFAULT NULL,
  `scanner_ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `scan_count` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `is_valid` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `price_alerts`
--

CREATE TABLE `price_alerts` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `property_id` int(10) UNSIGNED NOT NULL,
  `alert_price` decimal(15,2) DEFAULT NULL COMMENT 'NULL = أشعرني عند أي تغيير',
  `direction` enum('any','drop','rise') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'any',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `triggered_at` timestamp NULL DEFAULT NULL COMMENT 'وقت آخر إشعار تم إرساله',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `properties`
--

CREATE TABLE `properties` (
  `id` int(10) UNSIGNED NOT NULL,
  `owner_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `price` decimal(15,2) NOT NULL,
  `listing_type` enum('sale','rent') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'sale',
  `property_type` enum('villa','apartment','commercial','land','office') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'apartment',
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `district` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('available','sold','rented','pending','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'available',
  `bedrooms` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `bathrooms` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `area` decimal(10,2) DEFAULT NULL COMMENT 'Area in square meters',
  `floor` int(11) DEFAULT NULL,
  `total_floors` int(11) DEFAULT NULL,
  `year_built` year(4) DEFAULT NULL,
  `is_furnished` tinyint(1) NOT NULL DEFAULT '0',
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `virtual_tour_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `views_count` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `admin_approved` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `properties`
--

INSERT INTO `properties` (`id`, `owner_id`, `title`, `description`, `price`, `listing_type`, `property_type`, `location`, `city`, `district`, `status`, `bedrooms`, `bathrooms`, `area`, `floor`, `total_floors`, `year_built`, `is_furnished`, `latitude`, `longitude`, `virtual_tour_url`, `views_count`, `is_featured`, `admin_approved`, `created_at`, `updated_at`) VALUES
(1, 2, 'فيلا فاخرة مع مسبح خاص', 'فيلا مذهلة من 5 غرف نوم مع مسبح خاص وحديقة ونظام منزل ذكي. مثالية للعائلات الباحثة عن الفخامة والراحة. تتميز بتصميم معماري حديث وتشطيبات عالية الجودة.', '2500000.00', 'sale', 'villa', 'الملقا، الرياض', 'الرياض', NULL, 'available', 5, 4, '450.00', NULL, NULL, NULL, 0, NULL, NULL, 'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=600&auto=format&fit=crop', 0, 1, 1, '2026-04-11 07:42:49', '2026-04-11 07:42:49'),
(2, 2, 'شقة عصرية وسط المدينة', 'شقة أنيقة من غرفتين نوم في قلب المدينة. قريبة من المراكز التجارية ووسائل النقل. مؤثثة بالكامل بأحدث التصاميم.', '850000.00', 'sale', 'apartment', 'البلد، جدة', 'جدة', NULL, 'available', 2, 2, '120.00', NULL, NULL, NULL, 0, NULL, NULL, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=600&auto=format&fit=crop', 0, 1, 1, '2026-04-11 07:42:49', '2026-04-11 07:42:49'),
(3, 2, 'مكتب تجاري واسع', 'مساحة مكتبية واسعة ومفتوحة مناسبة للشركات الناشئة. إنترنت عالي السرعة ومواقف سيارات مخصصة وقاعة اجتماعات.', '120000.00', 'rent', 'commercial', 'طريق الملك فهد، الدمام', 'الدمام', NULL, 'available', 0, 2, '200.00', NULL, NULL, NULL, 0, NULL, NULL, 'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop', 0, 0, 1, '2026-04-11 07:42:49', '2026-04-11 07:42:49'),
(4, 2, 'شقة للإيجار في الرياض', 'شقة مريحة من 3 غرف نوم في حي هادئ. تشمل غرفة معيشة واسعة ومطبخاً حديثاً وموقف سيارة خاصاً.', '45000.00', 'rent', 'apartment', 'النرجس، الرياض', 'الرياض', NULL, 'available', 3, 2, '180.00', NULL, NULL, NULL, 0, NULL, NULL, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop', 0, 0, 1, '2026-04-11 07:42:49', '2026-04-11 07:42:49'),
(5, 2, 'أرض سكنية للبيع', 'أرض سكنية مميزة في منطقة متطورة. مساحة كبيرة مناسبة لبناء فيلا أحلامك. قريبة من الخدمات والمدارس.', '1800000.00', 'sale', 'land', 'العارض، الرياض', 'الرياض', NULL, 'available', 0, 0, '800.00', NULL, NULL, NULL, 0, NULL, NULL, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=600&auto=format&fit=crop', 0, 0, 1, '2026-04-11 07:42:49', '2026-04-11 07:42:49'),
(6, 2, 'فيلا للإيجار في جدة', 'فيلا راقية مع حديقة خاصة ومسبح. موقع ممتاز قريب من البحر. مناسبة للعائلات الكبيرة.', '180000.00', 'rent', 'villa', 'الزهراء، جدة', 'جدة', NULL, 'available', 6, 5, '600.00', NULL, NULL, NULL, 0, NULL, NULL, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&auto=format&fit=crop', 0, 1, 1, '2026-04-11 07:42:49', '2026-04-11 07:42:49'),
(7, 2, 'مكتب للإيجار في الدمام', 'مكتب حديث في برج تجاري مرموق. إطلالة رائعة وموقع استراتيجي. مناسب للشركات الكبيرة.', '85000.00', 'rent', 'office', 'العزيزية، الدمام', 'الدمام', NULL, 'available', 0, 2, '150.00', NULL, NULL, NULL, 0, NULL, NULL, 'https://images.unsplash.com/photo-1497366754035-f200581384c9?q=80&w=600&auto=format&fit=crop', 0, 0, 1, '2026-04-11 07:42:49', '2026-04-11 07:42:49'),
(8, 2, 'شقة فندقية فاخرة', 'شقة فندقية مفروشة بالكامل في برج سكني فاخر. خدمات كاملة تشمل الأمن والمسبح والصالة الرياضية.', '1200000.00', 'sale', 'apartment', 'العليا، الرياض', 'الرياض', NULL, 'available', 2, 2, '140.00', NULL, NULL, NULL, 0, NULL, NULL, 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?q=80&w=600&auto=format&fit=crop', 0, 1, 1, '2026-04-11 07:42:49', '2026-04-11 07:42:49');

-- --------------------------------------------------------

--
-- Table structure for table `property_features`
--

CREATE TABLE `property_features` (
  `id` int(10) UNSIGNED NOT NULL,
  `property_id` int(10) UNSIGNED NOT NULL,
  `feature_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'e.g. Swimming Pool, Gym, Parking, Elevator, Security'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `property_images`
--

CREATE TABLE `property_images` (
  `id` int(10) UNSIGNED NOT NULL,
  `property_id` int(10) UNSIGNED NOT NULL,
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `sort_order` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `property_images`
--

INSERT INTO `property_images` (`id`, `property_id`, `image_url`, `is_primary`, `sort_order`, `created_at`) VALUES
(1, 1, 'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=600&auto=format&fit=crop', 1, 0, '2026-04-11 07:42:49'),
(2, 1, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&auto=format&fit=crop', 0, 1, '2026-04-11 07:42:49'),
(3, 1, 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=600&auto=format&fit=crop', 0, 2, '2026-04-11 07:42:49'),
(4, 2, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=600&auto=format&fit=crop', 1, 0, '2026-04-11 07:42:49'),
(5, 2, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop', 0, 1, '2026-04-11 07:42:49'),
(6, 3, 'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop', 1, 0, '2026-04-11 07:42:49'),
(7, 4, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop', 1, 0, '2026-04-11 07:42:49'),
(8, 5, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=600&auto=format&fit=crop', 1, 0, '2026-04-11 07:42:49'),
(9, 6, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&auto=format&fit=crop', 1, 0, '2026-04-11 07:42:49'),
(10, 7, 'https://images.unsplash.com/photo-1497366754035-f200581384c9?q=80&w=600&auto=format&fit=crop', 1, 0, '2026-04-11 07:42:49'),
(11, 8, 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?q=80&w=600&auto=format&fit=crop', 1, 0, '2026-04-11 07:42:49');

-- --------------------------------------------------------

--
-- Table structure for table `property_views`
--

CREATE TABLE `property_views` (
  `id` int(10) UNSIGNED NOT NULL,
  `property_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'NULL = زائر غير مسجل',
  `viewed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `property_id` int(10) UNSIGNED DEFAULT NULL,
  `agency_id` int(10) UNSIGNED DEFAULT NULL,
  `rating` tinyint(3) UNSIGNED NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`id`, `user_id`, `property_id`, `agency_id`, `rating`, `comment`, `created_at`) VALUES
(1, 1, 1, NULL, 5, 'تللل', '2026-05-05 05:21:06');

-- --------------------------------------------------------

--
-- Table structure for table `search_history`
--

CREATE TABLE `search_history` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `search_query` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `filters` json DEFAULT NULL COMMENT 'Filter parameters as JSON object',
  `results_count` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `searched_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('tenant','buyer','seller','owner','agency','admin') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'buyer',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text COLLATE utf8mb4_unicode_ci,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `fcm_token` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Firebase Cloud Messaging token for push notifications',
  `last_login_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `phone`, `avatar`, `bio`, `is_verified`, `is_active`, `fcm_token`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'منور العامري', 'admin@aqari.com', '$2y$10$Bb3oA7tvSV9HWDTFqgEmUuXyBAJqweHB6RAPzWOxKakgj8r6PZPjS', 'admin', '220841258', NULL, 'r', 1, 1, NULL, '2026-05-11 00:34:15', '2026-04-11 07:42:26', '2026-05-11 00:34:15'),
(2, 'Ahmed Al-Malki', 'ahmed@aqari.com', '$2y$10$Bb3oA7tvSV9HWDTFqgEmUuXyBAJqweHB6RAPzWOxKakgj8r6PZPjS', 'owner', '+966500000002', NULL, NULL, 1, 1, NULL, NULL, '2026-04-11 07:42:26', '2026-04-11 09:36:13'),
(3, 'Sara Al-Zahrani', 'sara123@aqari.com', '$2y$10$Bb3oA7tvSV9HWDTFqgEmUuXyBAJqweHB6RAPzWOxKakgj8r6PZPjS', 'buyer', '+966500000003', NULL, NULL, 1, 1, NULL, NULL, '2026-04-11 07:42:26', '2026-04-11 09:43:10'),
(4, 'Fatima Al-Otaibi', 'fatima@aqari.com', '$2y$10$Bb3oA7tvSV9HWDTFqgEmUuXyBAJqweHB6RAPzWOxKakgj8r6PZPjS', 'tenant', '+966500000005', NULL, NULL, 1, 1, NULL, NULL, '2026-04-11 07:42:26', '2026-04-11 09:36:13'),
(5, 'Mohammed Seller', 'seller@aqari.com', '$2y$10$Bb3oA7tvSV9HWDTFqgEmUuXyBAJqweHB6RAPzWOxKakgj8r6PZPjS', 'seller', '+966500000006', NULL, NULL, 1, 1, NULL, '2026-05-05 04:58:23', '2026-04-11 07:42:26', '2026-05-05 04:58:23');

-- --------------------------------------------------------

--
-- Table structure for table `user_preferences`
--

CREATE TABLE `user_preferences` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `preferred_types` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'JSON array e.g. ["villa","apartment"]',
  `preferred_listing` enum('sale','rent','both') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'both',
  `min_price` decimal(15,2) DEFAULT NULL,
  `max_price` decimal(15,2) DEFAULT NULL,
  `min_area` decimal(10,2) DEFAULT NULL,
  `max_area` decimal(10,2) DEFAULT NULL,
  `min_bedrooms` int(10) UNSIGNED DEFAULT NULL,
  `preferred_cities` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'JSON array e.g. ["Riyadh","Jeddah"]',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `agencies`
--
ALTER TABLE `agencies`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_agency_user` (`user_id`),
  ADD KEY `idx_agency_city` (`city`),
  ADD KEY `idx_agency_rating` (`rating_avg`);

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_apt_owner` (`owner_id`),
  ADD KEY `idx_apt_status` (`status`),
  ADD KEY `idx_apt_property` (`property_id`),
  ADD KEY `idx_apt_user` (`user_id`);

--
-- Indexes for table `contracts`
--
ALTER TABLE `contracts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_contract_number` (`contract_number`),
  ADD KEY `idx_con_status` (`status`),
  ADD KEY `idx_con_buyer` (`buyer_id`),
  ADD KEY `idx_con_seller` (`seller_id`),
  ADD KEY `idx_con_property` (`property_id`);

--
-- Indexes for table `contract_signatures`
--
ALTER TABLE `contract_signatures`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_sig` (`contract_id`,`user_id`),
  ADD KEY `fk_sig_user` (`user_id`),
  ADD KEY `idx_sig_contract` (`contract_id`);

--
-- Indexes for table `conversations`
--
ALTER TABLE `conversations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_conv_property` (`property_id`);

--
-- Indexes for table `conversation_participants`
--
ALTER TABLE `conversation_participants`
  ADD PRIMARY KEY (`conversation_id`,`user_id`),
  ADD KEY `fk_cp_user` (`user_id`);

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_fav` (`user_id`,`property_id`),
  ADD KEY `fk_fav_property` (`property_id`);

--
-- Indexes for table `market_stats`
--
ALTER TABLE `market_stats`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_market_stat` (`city`,`property_type`,`listing_type`,`recorded_month`),
  ADD KEY `idx_ms_city` (`city`),
  ADD KEY `idx_ms_month` (`recorded_month`),
  ADD KEY `idx_ms_type` (`property_type`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_msg_sender` (`sender_id`),
  ADD KEY `idx_conv_msg` (`conversation_id`,`created_at`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_read` (`user_id`,`is_read`),
  ADD KEY `idx_user_type` (`user_id`,`type`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_transaction` (`transaction_id`),
  ADD KEY `fk_pay_property` (`property_id`),
  ADD KEY `idx_pay_status` (`status`),
  ADD KEY `idx_pay_payer` (`payer_id`),
  ADD KEY `idx_pay_payee` (`payee_id`),
  ADD KEY `idx_pay_contract` (`contract_id`),
  ADD KEY `idx_pay_created_at` (`created_at`);

--
-- Indexes for table `payment_verifications`
--
ALTER TABLE `payment_verifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_verification_code` (`verification_code`),
  ADD KEY `idx_pv_payment` (`payment_id`),
  ADD KEY `idx_pv_code` (`verification_code`);

--
-- Indexes for table `price_alerts`
--
ALTER TABLE `price_alerts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_alert` (`user_id`,`property_id`),
  ADD KEY `idx_pa_active` (`is_active`),
  ADD KEY `idx_pa_property` (`property_id`);

--
-- Indexes for table `properties`
--
ALTER TABLE `properties`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_property_type` (`property_type`),
  ADD KEY `idx_listing_type` (`listing_type`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_prop_city` (`city`),
  ADD KEY `idx_price` (`price`),
  ADD KEY `idx_bedrooms` (`bedrooms`),
  ADD KEY `idx_featured` (`is_featured`),
  ADD KEY `idx_owner` (`owner_id`);

--
-- Indexes for table `property_features`
--
ALTER TABLE `property_features`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_property_features` (`property_id`);

--
-- Indexes for table `property_images`
--
ALTER TABLE `property_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_property_primary` (`property_id`,`is_primary`);

--
-- Indexes for table `property_views`
--
ALTER TABLE `property_views`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_views` (`user_id`),
  ADD KEY `idx_property_views` (`property_id`),
  ADD KEY `idx_viewed_at` (`viewed_at`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_review_user` (`user_id`),
  ADD KEY `idx_property_rating` (`property_id`,`rating`),
  ADD KEY `idx_agency_rating` (`agency_id`,`rating`);

--
-- Indexes for table `search_history`
--
ALTER TABLE `search_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_search` (`user_id`),
  ADD KEY `idx_search_date` (`searched_at`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_email` (`email`),
  ADD KEY `idx_role` (`role`),
  ADD KEY `idx_is_active` (`is_active`);

--
-- Indexes for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pref_user` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `agencies`
--
ALTER TABLE `agencies`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `contracts`
--
ALTER TABLE `contracts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `contract_signatures`
--
ALTER TABLE `contract_signatures`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `conversations`
--
ALTER TABLE `conversations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `market_stats`
--
ALTER TABLE `market_stats`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payment_verifications`
--
ALTER TABLE `payment_verifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `price_alerts`
--
ALTER TABLE `price_alerts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `property_features`
--
ALTER TABLE `property_features`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `property_images`
--
ALTER TABLE `property_images`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `property_views`
--
ALTER TABLE `property_views`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `search_history`
--
ALTER TABLE `search_history`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user_preferences`
--
ALTER TABLE `user_preferences`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `agencies`
--
ALTER TABLE `agencies`
  ADD CONSTRAINT `agencies_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointments_ibfk_3` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `contracts`
--
ALTER TABLE `contracts`
  ADD CONSTRAINT `contracts_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `contracts_ibfk_2` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `contracts_ibfk_3` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `contract_signatures`
--
ALTER TABLE `contract_signatures`
  ADD CONSTRAINT `contract_signatures_ibfk_1` FOREIGN KEY (`contract_id`) REFERENCES `contracts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `contract_signatures_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `conversations`
--
ALTER TABLE `conversations`
  ADD CONSTRAINT `conversations_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `conversation_participants`
--
ALTER TABLE `conversation_participants`
  ADD CONSTRAINT `conversation_participants_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `conversation_participants_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `favorites`
--
ALTER TABLE `favorites`
  ADD CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`contract_id`) REFERENCES `contracts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`payer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`payee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payments_ibfk_4` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `payment_verifications`
--
ALTER TABLE `payment_verifications`
  ADD CONSTRAINT `payment_verifications_ibfk_1` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `price_alerts`
--
ALTER TABLE `price_alerts`
  ADD CONSTRAINT `price_alerts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `price_alerts_ibfk_2` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `properties`
--
ALTER TABLE `properties`
  ADD CONSTRAINT `properties_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `property_features`
--
ALTER TABLE `property_features`
  ADD CONSTRAINT `property_features_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `property_images`
--
ALTER TABLE `property_images`
  ADD CONSTRAINT `property_images_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `property_views`
--
ALTER TABLE `property_views`
  ADD CONSTRAINT `property_views_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `property_views_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_3` FOREIGN KEY (`agency_id`) REFERENCES `agencies` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `search_history`
--
ALTER TABLE `search_history`
  ADD CONSTRAINT `search_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD CONSTRAINT `user_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
