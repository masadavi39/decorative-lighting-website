-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3386
-- Generation Time: Dec 02, 2025 at 11:31 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `light_csdl`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `apply_coupon_logic` (IN `p_coupon_code` VARCHAR(50), IN `p_subtotal` DECIMAL(10,2), OUT `o_valid` TINYINT(1))   BEGIN
    DECLARE v_start DATETIME;
    DECLARE v_end DATETIME;
    DECLARE v_usage_limit INT;
    DECLARE v_used_count INT;
    DECLARE v_min_sub DECIMAL(10,2);
    DECLARE v_active TINYINT(1);

    SET o_valid = 0;

    IF p_coupon_code IS NULL OR p_coupon_code = '' THEN
        SET o_valid = 1;
    ELSE
        SELECT start_at, end_at, usage_limit, used_count, min_subtotal, active
          INTO v_start, v_end, v_usage_limit, v_used_count, v_min_sub, v_active
        FROM coupons
        WHERE code = p_coupon_code
        LIMIT 1;

        IF ROW_COUNT() > 0 THEN
            IF v_active = 1
               AND NOW() BETWEEN v_start AND v_end
               AND (v_usage_limit IS NULL OR v_used_count < v_usage_limit)
               AND p_subtotal >= COALESCE(v_min_sub,0) THEN
                SET o_valid = 1;
            END IF;
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cleanup_expired_data` ()   BEGIN
    DELETE FROM remember_tokens WHERE expire_at < NOW();
    DELETE FROM emailotp        WHERE expire_at < NOW();
    DELETE FROM password_resets WHERE expire_at < NOW() AND used = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `recalc_order_total` (IN `p_order_id` INT)   BEGIN
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
    DECLARE v_shipping DECIMAL(10,2) DEFAULT 0;
    DECLARE v_tax DECIMAL(10,2) DEFAULT 0;
    DECLARE v_coupon_code VARCHAR(50);
    DECLARE v_type ENUM('percent','fixed');
    DECLARE v_value DECIMAL(10,2);
    DECLARE v_min_sub DECIMAL(10,2);
    DECLARE v_max DECIMAL(10,2);
    DECLARE v_active TINYINT(1);
    DECLARE v_discount DECIMAL(10,2) DEFAULT 0;

    SELECT COALESCE(SUM(od.quantity * od.price),0) INTO v_subtotal
    FROM order_details od WHERE od.order_id = p_order_id;

    SELECT shipping_fee, tax, coupon_code INTO v_shipping, v_tax, v_coupon_code
    FROM orders WHERE order_id = p_order_id LIMIT 1;

    IF v_tax = 0 THEN
        SET v_tax = ROUND(v_subtotal * 0.10, 2);
    END IF;

    IF v_coupon_code IS NOT NULL AND v_coupon_code <> '' THEN
        SELECT discount_type, value, min_subtotal, max_discount, active
          INTO v_type, v_value, v_min_sub, v_max, v_active
        FROM coupons WHERE code = v_coupon_code LIMIT 1;

        IF v_active = 1 AND v_subtotal >= COALESCE(v_min_sub,0) THEN
            IF v_type = 'percent' THEN
                SET v_discount = ROUND(v_subtotal * (v_value/100), 2);
                IF v_max IS NOT NULL THEN
                    SET v_discount = LEAST(v_discount, v_max);
                END IF;
            ELSE
                SET v_discount = LEAST(v_value, v_subtotal);
            END IF;
        END IF;
    END IF;

    UPDATE orders
       SET tax = v_tax,
           discount_amount = v_discount,
           total_price = v_subtotal + v_shipping + v_tax - v_discount
     WHERE order_id = p_order_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `parent_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `name`, `parent_id`) VALUES
(1, 'Chiếu sáng trong nhà', NULL),
(2, 'Chiếu sáng ngoài trời', NULL),
(3, 'Đèn chùm', 1),
(4, 'Đèn tường', 1),
(5, 'Đèn bàn', 1),
(6, 'Đèn ốp trần', 1),
(7, 'Đèn sân vườn', 2),
(8, 'Đèn pha', 2),
(9, 'Đèn trụ cổng', 2);

-- --------------------------------------------------------

--
-- Table structure for table `chat_messages`
--

CREATE TABLE `chat_messages` (
  `chat_message_id` int(11) NOT NULL,
  `user_id` varchar(64) NOT NULL,
  `sender_type` enum('USER','ADMIN') NOT NULL,
  `message_content` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chat_messages`
--

INSERT INTO `chat_messages` (`chat_message_id`, `user_id`, `sender_type`, `message_content`, `created_at`) VALUES
(1, '1', 'USER', 'Xin chào shop!', '2025-11-29 04:56:11'),
(2, '1', 'ADMIN', 'Shop chào bạn, mình hỗ trợ gì ạ?', '2025-11-29 04:56:11'),
(3, '1', 'ADMIN', 'oke', '2025-11-29 04:57:34'),
(4, '36f026b0c0d6ac4f5dbac862c1ba', 'USER', 'Hello', '2025-11-30 06:24:40'),
(5, '36f026b0c0d6ac4f5dbac862c1ba', 'ADMIN', 'hello', '2025-11-30 06:25:12'),
(6, '21', 'USER', 'hello', '2025-12-01 11:16:14'),
(7, '21', 'ADMIN', '?', '2025-12-01 11:16:31');

-- --------------------------------------------------------

--
-- Table structure for table `coupons`
--

CREATE TABLE `coupons` (
  `coupon_id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `discount_type` enum('percent','fixed') NOT NULL,
  `value` decimal(10,2) NOT NULL,
  `max_discount` decimal(10,2) DEFAULT NULL,
  `start_at` datetime NOT NULL,
  `end_at` datetime NOT NULL,
  `usage_limit` int(11) DEFAULT NULL,
  `used_count` int(11) NOT NULL DEFAULT 0,
  `min_subtotal` decimal(10,2) DEFAULT 0.00,
  `active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `coupons`
--

INSERT INTO `coupons` (`coupon_id`, `code`, `description`, `discount_type`, `value`, `max_discount`, `start_at`, `end_at`, `usage_limit`, `used_count`, `min_subtotal`, `active`) VALUES
(1, 'SAVE10', 'giảm 10%', 'percent', 10.00, 200000.00, '2025-11-29 17:00:00', '2025-11-29 17:00:00', 1, 0, 0.00, 1),
(2, 'DA', '1', 'percent', 10.00, 10000.00, '2025-11-30 17:00:00', '2025-12-09 17:00:00', 500, 0, 0.00, 1),
(3, 'SAVE100', '100%', 'percent', 100.00, 1000000.00, '2025-11-29 17:00:00', '2025-12-03 16:59:59', 2, 2, 0.00, 1);

-- --------------------------------------------------------

--
-- Table structure for table `emailotp`
--

CREATE TABLE `emailotp` (
  `otp_id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `otp_code` varchar(6) NOT NULL,
  `expire_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feedback`
--

CREATE TABLE `feedback` (
  `feedback_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `feedback`
--

INSERT INTO `feedback` (`feedback_id`, `name`, `email`, `message`, `created_at`) VALUES
(1, 'Homei', 'hoangngocduythptlucnam@gmail.com', 'dsds', '2025-11-05 03:04:43'),
(2, 'Phạm Anh Núi', 'duy@example.com', 'nhin cai gi', '2025-11-11 02:07:43'),
(3, 'Tranh', 'lopa59733@gmail.com', 's', '2025-11-29 04:59:10');

-- --------------------------------------------------------

--
-- Table structure for table `inventory_movements`
--

CREATE TABLE `inventory_movements` (
  `inventory_movement_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `order_detail_id` int(11) DEFAULT NULL,
  `movement_type` enum('sale','return','manual_adjust') NOT NULL,
  `quantity_change` int(11) NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventory_movements`
--

INSERT INTO `inventory_movements` (`inventory_movement_id`, `product_id`, `order_detail_id`, `movement_type`, `quantity_change`, `note`, `created_at`) VALUES
(1, 32, 1, 'sale', -1, 'Bán hàng', '2025-11-16 09:46:54'),
(2, 32, NULL, 'sale', -1, 'Bán hàng', '2025-11-16 09:52:43'),
(4, 32, 3, 'sale', -1, 'Bán hàng', '2025-11-16 10:18:47'),
(5, 33, 4, 'sale', -1, 'Bán hàng', '2025-11-16 12:16:59'),
(6, 32, NULL, 'sale', -1, 'Bán hàng', '2025-11-25 06:33:11'),
(7, 31, NULL, 'sale', -1, 'Bán hàng', '2025-11-25 07:34:04'),
(10, 33, 7, 'sale', -1, 'Bán hàng', '2025-11-29 05:03:09'),
(11, 28, 8, 'sale', -1, 'Bán hàng', '2025-11-30 05:52:15'),
(12, 1, NULL, 'manual_adjust', 10, 'Restock nhanh +10', '2025-12-01 07:42:52'),
(13, 14, NULL, 'manual_adjust', 10, 'Restock nhanh +10', '2025-12-01 07:42:54'),
(14, 4, NULL, 'manual_adjust', 10, 'Restock nhanh +10', '2025-12-01 07:43:08'),
(15, 28, NULL, 'sale', -1, 'Bán hàng', '2025-12-01 10:31:17'),
(16, 28, 10, 'sale', -1, 'Bán hàng', '2025-12-01 11:01:54');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `payment_id` int(11) NOT NULL,
  `receiver_name` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `province_id` int(11) NOT NULL,
  `address` varchar(255) NOT NULL,
  `shipping_method` enum('standard','express','overnight') NOT NULL DEFAULT 'standard',
  `shipping_fee` decimal(10,2) NOT NULL DEFAULT 0.00,
  `invoice_company` varchar(255) DEFAULT NULL,
  `tax_code` varchar(50) DEFAULT NULL,
  `tax_email` varchar(100) DEFAULT NULL,
  `note` text DEFAULT NULL,
  `tax` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `coupon_code` varchar(50) DEFAULT NULL,
  `total_price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `status` enum('Chờ duyệt','Đang giao','Đã giao','Đã hủy') NOT NULL DEFAULT 'Chờ duyệt',
  `payment_status` enum('pending','paid','refunded','failed') NOT NULL DEFAULT 'pending',
  `tracking_number` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `user_id`, `payment_id`, `receiver_name`, `phone`, `province_id`, `address`, `shipping_method`, `shipping_fee`, `invoice_company`, `tax_code`, `tax_email`, `note`, `tax`, `discount_amount`, `coupon_code`, `total_price`, `status`, `payment_status`, `tracking_number`, `created_at`, `updated_at`) VALUES
(9, 21, 2, 'Anh', '0912', 1, '123', 'standard', 30000.00, NULL, NULL, NULL, '', 67000.00, 0.00, NULL, 767000.00, 'Chờ duyệt', 'pending', NULL, '2025-11-16 09:46:54', '2025-11-16 09:46:54'),
(11, 14, 2, 'Fourteen', '211312', 15, 'aaa', 'standard', 30000.00, NULL, NULL, NULL, '', 67000.00, 0.00, NULL, 767000.00, 'Đã hủy', 'pending', NULL, '2025-11-16 10:18:47', '2025-12-01 09:32:36'),
(12, 21, 2, 'A', '1231', 15, '123', 'standard', 30000.00, NULL, NULL, NULL, '', 14500.00, 0.00, NULL, 189500.00, 'Đã giao', 'pending', NULL, '2025-11-16 12:16:59', '2025-11-29 05:01:25'),
(15, 21, 1, 'a', '09', 1, 'a', 'standard', 30000.00, NULL, NULL, NULL, '', 14500.00, 0.00, NULL, 189500.00, 'Đã giao', 'pending', NULL, '2025-11-29 05:03:09', '2025-11-29 05:03:41'),
(16, 21, 2, 'A', '090', 1, 'A', 'standard', 30000.00, NULL, NULL, NULL, '', 135000.00, 0.00, NULL, 1515000.00, 'Đã giao', 'pending', NULL, '2025-11-30 05:52:15', '2025-11-30 05:52:44'),
(18, 21, 2, 'A', '123', 15, 'A', 'standard', 30000.00, NULL, NULL, NULL, '', 135000.00, 1000000.00, 'SAVE100', 515000.00, 'Đã giao', 'pending', NULL, '2025-12-01 11:01:54', '2025-12-01 11:03:11');

--
-- Triggers `orders`
--
DELIMITER $$
CREATE TRIGGER `au_orders_increment_coupon_usage` AFTER UPDATE ON `orders` FOR EACH ROW BEGIN
    IF NEW.status = 'Đã giao'
       AND OLD.status <> 'Đã giao'
       AND NEW.coupon_code IS NOT NULL
       AND NEW.coupon_code <> '' THEN
        UPDATE coupons
        SET used_count = used_count + 1
        WHERE code = NEW.coupon_code
          AND (usage_limit IS NULL OR used_count < usage_limit);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `au_orders_log_history` AFTER UPDATE ON `orders` FOR EACH ROW BEGIN
    IF (OLD.status <> NEW.status) OR (OLD.shipping_method <> NEW.shipping_method) THEN
        INSERT INTO order_history (order_id, old_status, new_status, old_shipping, new_shipping, changed_by, change_note)
        VALUES (NEW.order_id, OLD.status, NEW.status, OLD.shipping_method, NEW.shipping_method, NULL, NULL);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `au_orders_recalc_after_update` AFTER UPDATE ON `orders` FOR EACH ROW BEGIN
    IF (NEW.coupon_code <> OLD.coupon_code)
       OR (NEW.shipping_method <> OLD.shipping_method) THEN
        CALL recalc_order_total(NEW.order_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `bi_orders_set_shipping` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
    IF NEW.shipping_fee IS NULL OR NEW.shipping_fee = 0 THEN
        CASE NEW.shipping_method
            WHEN 'standard' THEN SET NEW.shipping_fee = 30000;
            WHEN 'express' THEN SET NEW.shipping_fee = 60000;
            WHEN 'overnight' THEN SET NEW.shipping_fee = 120000;
            ELSE SET NEW.shipping_fee = 30000;
        END CASE;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `bi_orders_validate_coupon` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
    DECLARE v_valid TINYINT(1);
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
    CALL apply_coupon_logic(NEW.coupon_code, v_subtotal, v_valid);
    IF v_valid = 0 AND NEW.coupon_code IS NOT NULL AND NEW.coupon_code <> '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Coupon không hợp lệ hoặc chưa đạt điều kiện.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `bu_orders_adjust_shipping_method` BEFORE UPDATE ON `orders` FOR EACH ROW BEGIN
    IF NEW.shipping_method <> OLD.shipping_method
       AND OLD.status NOT IN ('Đã giao','Đã hủy') THEN
        CASE NEW.shipping_method
            WHEN 'standard' THEN SET NEW.shipping_fee = 30000;
            WHEN 'express' THEN SET NEW.shipping_fee = 60000;
            WHEN 'overnight' THEN SET NEW.shipping_fee = 120000;
            ELSE SET NEW.shipping_fee = 30000;
        END CASE;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `bu_orders_lock_final` BEFORE UPDATE ON `orders` FOR EACH ROW BEGIN
    IF OLD.status IN ('Đã giao','Đã hủy') THEN
        IF (NEW.receiver_name <> OLD.receiver_name)
           OR (NEW.address <> OLD.address)
           OR (NEW.province_id <> OLD.province_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Không sửa thông tin nhận hàng sau trạng thái cuối';
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `bu_orders_validate_coupon` BEFORE UPDATE ON `orders` FOR EACH ROW BEGIN
    DECLARE v_valid TINYINT(1);
    DECLARE v_subtotal DECIMAL(10,2);

    IF NEW.coupon_code <> OLD.coupon_code THEN
        SELECT COALESCE(SUM(od.quantity * od.price),0)
          INTO v_subtotal
        FROM order_details od
        WHERE od.order_id = OLD.order_id;

        CALL apply_coupon_logic(NEW.coupon_code, v_subtotal, v_valid);
        IF v_valid = 0 AND NEW.coupon_code IS NOT NULL AND NEW.coupon_code <> '' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Coupon không hợp lệ khi cập nhật.';
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `order_details`
--

CREATE TABLE `order_details` (
  `order_detail_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_details`
--

INSERT INTO `order_details` (`order_detail_id`, `order_id`, `product_id`, `quantity`, `price`, `created_at`, `updated_at`) VALUES
(1, 9, 32, 1, 670000.00, '2025-11-16 09:46:54', '2025-11-16 09:46:54'),
(3, 11, 32, 1, 670000.00, '2025-11-16 10:18:47', '2025-11-16 10:18:47'),
(4, 12, 33, 1, 145000.00, '2025-11-16 12:16:59', '2025-11-16 12:16:59'),
(7, 15, 33, 1, 145000.00, '2025-11-29 05:03:09', '2025-11-29 05:03:09'),
(8, 16, 28, 1, 1350000.00, '2025-11-30 05:52:15', '2025-11-30 05:52:15'),
(10, 18, 28, 1, 1350000.00, '2025-12-01 11:01:54', '2025-12-01 11:01:54');

--
-- Triggers `order_details`
--
DELIMITER $$
CREATE TRIGGER `ad_order_details_inventory_log` AFTER DELETE ON `order_details` FOR EACH ROW BEGIN
  INSERT INTO inventory_movements (product_id, order_detail_id, movement_type, quantity_change, note)
  VALUES (OLD.product_id, OLD.order_detail_id, 'manual_adjust', OLD.quantity, 'Xóa dòng chi tiết - hoàn kho');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ad_order_details_restore_inventory` AFTER DELETE ON `order_details` FOR EACH ROW BEGIN
    UPDATE products
       SET quantity = quantity + OLD.quantity,
           sold_quantity = sold_quantity - OLD.quantity
     WHERE product_id = OLD.product_id;

    CALL recalc_order_total(OLD.order_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ai_order_details_adjust_inventory` AFTER INSERT ON `order_details` FOR EACH ROW BEGIN
    UPDATE products
       SET quantity = quantity - NEW.quantity,
           sold_quantity = sold_quantity + NEW.quantity
     WHERE product_id = NEW.product_id;

    CALL recalc_order_total(NEW.order_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ai_order_details_inventory_log` AFTER INSERT ON `order_details` FOR EACH ROW BEGIN
  INSERT INTO inventory_movements (product_id, order_detail_id, movement_type, quantity_change, note)
  VALUES (NEW.product_id, NEW.order_detail_id, 'sale', -NEW.quantity, 'Bán hàng');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `au_order_details_adjust_inventory` AFTER UPDATE ON `order_details` FOR EACH ROW BEGIN
    DECLARE v_delta INT;
    SET v_delta = NEW.quantity - OLD.quantity;

    IF v_delta <> 0 THEN
        UPDATE products
           SET quantity = quantity - v_delta,
               sold_quantity = sold_quantity + v_delta
         WHERE product_id = NEW.product_id;
    END IF;

    IF v_delta <> 0 OR NEW.price <> OLD.price THEN
        CALL recalc_order_total(NEW.order_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `au_order_details_inventory_log` AFTER UPDATE ON `order_details` FOR EACH ROW BEGIN
  DECLARE v_delta INT;
  SET v_delta = NEW.quantity - OLD.quantity;
  IF v_delta <> 0 THEN
    INSERT INTO inventory_movements (product_id, order_detail_id, movement_type, quantity_change, note)
    VALUES (NEW.product_id, NEW.order_detail_id, 'manual_adjust', -v_delta, 'Điều chỉnh số lượng dòng chi tiết');
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `bi_order_details_validate_stock` BEFORE INSERT ON `order_details` FOR EACH ROW BEGIN
    DECLARE v_available INT;
    DECLARE v_price DECIMAL(10,2);

    IF NEW.quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Số lượng phải > 0';
    END IF;

    SELECT quantity, price INTO v_available, v_price
    FROM products
    WHERE product_id = NEW.product_id
    FOR UPDATE;

    IF v_available IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Sản phẩm không tồn tại';
    END IF;

    IF NEW.quantity > v_available THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Không đủ tồn kho';
    END IF;

    IF NEW.price IS NULL OR NEW.price = 0 THEN
        SET NEW.price = v_price;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `bu_order_details_validate_stock` BEFORE UPDATE ON `order_details` FOR EACH ROW BEGIN
    DECLARE v_current_qty INT;
    DECLARE v_effective INT;

    IF NEW.quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Số lượng phải > 0 khi cập nhật';
    END IF;

    SELECT quantity INTO v_current_qty
    FROM products
    WHERE product_id = NEW.product_id
    FOR UPDATE;

    SET v_effective = v_current_qty + OLD.quantity;

    IF NEW.quantity > v_effective THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Không đủ tồn kho để cập nhật';
    END IF;

    IF NEW.product_id <> OLD.product_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Không đổi product_id; xóa & thêm mới.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `order_history`
--

CREATE TABLE `order_history` (
  `order_history_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `old_status` enum('Chờ duyệt','Đang giao','Đã giao','Đã hủy') DEFAULT NULL,
  `new_status` enum('Chờ duyệt','Đang giao','Đã giao','Đã hủy') DEFAULT NULL,
  `old_shipping` enum('standard','express','overnight') DEFAULT NULL,
  `new_shipping` enum('standard','express','overnight') DEFAULT NULL,
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed_by` int(11) DEFAULT NULL,
  `change_note` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_history`
--

INSERT INTO `order_history` (`order_history_id`, `order_id`, `old_status`, `new_status`, `old_shipping`, `new_shipping`, `changed_at`, `changed_by`, `change_note`) VALUES
(4, 12, 'Chờ duyệt', 'Đang giao', 'standard', 'standard', '2025-11-29 05:01:15', NULL, NULL),
(5, 12, 'Đang giao', 'Đã giao', 'standard', 'standard', '2025-11-29 05:01:25', NULL, NULL),
(6, 15, 'Chờ duyệt', 'Đang giao', 'standard', 'standard', '2025-11-29 05:03:26', NULL, NULL),
(7, 15, 'Đang giao', 'Đã giao', 'standard', 'standard', '2025-11-29 05:03:41', NULL, NULL),
(8, 16, 'Chờ duyệt', 'Đang giao', 'standard', 'standard', '2025-11-30 05:52:33', NULL, NULL),
(9, 16, 'Đang giao', 'Đã giao', 'standard', 'standard', '2025-11-30 05:52:44', NULL, NULL),
(10, 11, 'Chờ duyệt', 'Đang giao', 'standard', 'standard', '2025-12-01 09:30:41', NULL, NULL),
(11, 11, 'Đang giao', 'Đã hủy', 'standard', 'standard', '2025-12-01 09:32:36', NULL, NULL),
(12, 18, 'Chờ duyệt', 'Đang giao', 'standard', 'standard', '2025-12-01 11:02:49', NULL, NULL),
(13, 18, 'Đang giao', 'Đã giao', 'standard', 'standard', '2025-12-01 11:02:57', NULL, NULL),
(14, 18, 'Đã giao', 'Đang giao', 'standard', 'standard', '2025-12-01 11:03:07', NULL, NULL),
(15, 18, 'Đang giao', 'Đã giao', 'standard', 'standard', '2025-12-01 11:03:11', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_shipments`
--

CREATE TABLE `order_shipments` (
  `order_shipment_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `tracking_number` varchar(100) NOT NULL,
  `carrier` varchar(100) DEFAULT NULL,
  `shipped_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `status` enum('pending','shipped','delivered','returned') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `password_reset_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `expire_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `used` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payment_methods`
--

CREATE TABLE `payment_methods` (
  `payment_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment_methods`
--

INSERT INTO `payment_methods` (`payment_id`, `name`, `description`) VALUES
(1, 'Chuyển khoản', 'Thanh toán qua ngân hàng'),
(2, 'COD', 'Thanh toán khi nhận hàng');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `manufacturer` varchar(100) DEFAULT NULL,
  `quantity` int(11) UNSIGNED DEFAULT 0,
  `sold_quantity` int(11) UNSIGNED DEFAULT 0,
  `image_path` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `category_id`, `name`, `description`, `price`, `manufacturer`, `quantity`, `sold_quantity`, `image_path`) VALUES
(1, 3, 'Đèn chùm pha lê sang trọng', 'Đèn chùm pha lê cao cấp, ánh sáng ấm áp phù hợp phòng khách.', 2500000.00, 'Philips', 10, 3, 'images/denchum1.jpg'),
(2, 3, 'Đèn chùm hiện đại 6 bóng', 'Thiết kế hiện đại, chất liệu hợp kim cao cấp.', 2200000.00, 'Rạng Đông', 8, 2, 'images/denchum2.jpg'),
(3, 4, 'Đèn tường đôi trang trí', 'Đèn tường ánh sáng vàng, kiểu dáng cổ điển.', 850000.00, 'Paragon', 12, 4, 'images/dentuong1.jpg'),
(4, 4, 'Đèn tường gương hiện đại', 'Phù hợp phòng ngủ và phòng tắm.', 900000.00, 'Panasonic', 16, 1, 'images/dentuong2.jpg'),
(5, 5, 'Đèn bàn học chống cận', 'Đèn bàn LED 3 chế độ sáng, tiết kiệm điện.', 350000.00, 'Duhal', 15, 7, 'images/denban1.jpg'),
(6, 5, 'Đèn bàn cảm ứng đa năng', 'Đèn LED cảm ứng, sạc USB tiện lợi.', 420000.00, 'Philips', 9, 2, 'images/denban2.jpg'),
(7, 6, 'Đèn ốp trần LED tròn 24W', 'Đèn trần LED siêu sáng, tuổi thọ cao.', 480000.00, 'Duhal', 10, 5, 'images/optran1.jpg'),
(8, 6, 'Đèn ốp trần pha lê ốp nổi', 'Đèn trần pha lê sang trọng, ánh sáng trắng.', 680000.00, 'Paragon', 7, 1, 'images/optran2.jpg'),
(9, 7, 'Đèn sân vườn năng lượng mặt trời', 'Tự sạc ban ngày, chiếu sáng ban đêm tự động.', 520000.00, 'Philips', 20, 10, 'images/sanvuon1.jpg'),
(10, 7, 'Đèn sân vườn trang trí mini', 'Dễ lắp đặt, ánh sáng dịu, thích hợp lối đi.', 290000.00, 'Rạng Đông', 18, 4, 'images/sanvuon2.jpg'),
(11, 8, 'Đèn pha LED 50W ngoài trời', 'Chống nước IP65, ánh sáng trắng mạnh.', 750000.00, 'Duhal', 10, 6, 'images/denpha1.jpg'),
(12, 8, 'Đèn pha năng lượng mặt trời', 'Tự sạc bằng năng lượng mặt trời, tiết kiệm điện.', 950000.00, 'Paragon', 8, 3, 'images/denpha2.jpg'),
(13, 9, 'Đèn trụ cổng inox 25cm', 'Đèn trang trí trụ cổng ngoài trời, chống nước.', 680000.00, 'Panasonic', 6, 2, 'images/trucong1.jpg'),
(14, 9, 'Đèn trụ cổng năng lượng mặt trời', 'Tự động chiếu sáng khi trời tối.', 820000.00, 'Philips', 15, 1, 'images/trucong2.jpg'),
(15, 4, 'Đèn LED Bulb 5W Rạng Đông', 'Tiết kiệm điện, ánh sáng trắng 6500K, tuổi thọ 25.000h', 45000.00, NULL, 164, 28, 'images/den-led-bulb-5w.jpg'),
(16, 4, 'Đèn LED Bulb 9W Philips', 'Công suất 9W, ánh sáng vàng 3000K, bảo hành 2 năm', 65000.00, NULL, 7, 4, 'images/den-led-bulb-9w.jpg'),
(17, 4, 'Đèn LED Bulb 12W Điện Quang', 'Chiếu sáng mạnh, phù hợp phòng khách', 89000.00, NULL, 63, 28, 'images/den-led-bulb-12w.jpg'),
(18, 4, 'Đèn LED Bulb 18W Rạng Đông', 'Tiết kiệm điện, ánh sáng trắng tự nhiên', 115000.00, NULL, 36, 6, 'images/den-led-bulb-18w.jpg'),
(19, 6, 'Đèn ốp trần tròn 24W', 'Đèn ốp trần LED siêu sáng, tiết kiệm điện', 265000.00, NULL, 174, 139, 'images/den-op-tran-tron-24w.jpg'),
(20, 6, 'Đèn ốp trần vuông 18W', 'Thiết kế hiện đại, ánh sáng ấm', 225000.00, NULL, 23, 18, 'images/den-op-tran-vuong-18w.jpg'),
(21, 6, 'Đèn ốp trần cảm biến Rạng Đông', 'Tự động bật khi phát hiện chuyển động', 315000.00, NULL, 109, 4, 'images/den-op-tran-cambien.jpg'),
(22, 6, 'Đèn ốp trần mica cao cấp 36W', 'Trang trí phòng khách, ánh sáng vàng', 420000.00, NULL, 8, 1, 'images/den-op-tran-36w.jpg'),
(23, 8, 'Đèn đường LED 50W Rạng Đông', 'Chiếu sáng ngoài trời, đạt chuẩn IP66', 720000.00, NULL, 56, 14, 'images/den-duong-50w.jpg'),
(24, 8, 'Đèn đường năng lượng mặt trời 100W', 'Tự sạc năng lượng, cảm biến ngày đêm', 890000.00, NULL, 130, 6, 'images/den-duong-nangluong-100w.jpg'),
(25, 8, 'Đèn đường LED 150W Philips', 'Hiệu suất cao, dùng cho khu công nghiệp', 1250000.00, NULL, 144, 50, 'images/den-duong-150w.jpg'),
(26, 8, 'Đèn đường năng lượng 200W', 'Có remote điều khiển, pin lithium cao cấp', 1450000.00, NULL, 184, 166, 'images/den-duong-nangluong-200w.jpg'),
(27, 4, 'Đèn thả trần phong cách Bắc Âu', 'Thiết kế tinh tế, ánh sáng dịu nhẹ', 550000.00, NULL, 180, 139, 'images/den-tha-bac-au.jpg'),
(28, 4, 'Đèn chùm pha lê cao cấp', 'Phù hợp phòng khách, sang trọng', 1350000.00, NULL, 105, 31, 'images/den-chum-pha-le.jpg'),
(29, 4, 'Đèn tường vintage Edison', 'Trang trí quán cà phê, không gian cổ điển', 350000.00, NULL, 115, 75, 'images/den-vintage-edison.jpg'),
(30, 4, 'Đèn bàn học chống cận Rạng Đông', 'Ánh sáng tự nhiên, 3 chế độ sáng', 290000.00, NULL, 72, 0, 'images/den-ban-chong-can.jpg'),
(31, 5, 'Bộ nguồn LED 12V 5A', 'Nguồn tổ ong cho đèn LED, chất lượng cao', 99000.00, NULL, 194, 41, 'images/bo-nguon-12v5a.jpg'),
(32, 5, 'Dây điện lõi đồng Cadivi 2x1.5', 'Dây đôi cách điện PVC, dài 100m', 670000.00, NULL, 175, 112, 'images/day-dien-cadivi-2x1.5.jpg'),
(33, 5, 'Bộ chao đèn treo trần', 'Phụ kiện trang trí, chao nhôm trắng', 145000.00, NULL, 86, 37, 'images/chao-den-treo-tran.jpg'),
(34, 5, 'Đui đèn cảm ứng ánh sáng', 'Tự động bật khi trời tối, tắt khi sáng', 120000.00, NULL, 40, 13, 'images/dui-den-cambien.jpg');

--
-- Triggers `products`
--
DELIMITER $$
CREATE TRIGGER `au_products_log_price_change` AFTER UPDATE ON `products` FOR EACH ROW BEGIN
    IF NEW.price <> OLD.price THEN
        INSERT INTO product_price_history (product_id, old_price, new_price)
        VALUES (NEW.product_id, OLD.price, NEW.price);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `product_price_history`
--

CREATE TABLE `product_price_history` (
  `product_price_history_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `old_price` decimal(10,2) NOT NULL,
  `new_price` decimal(10,2) NOT NULL,
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_reviews`
--

CREATE TABLE `product_reviews` (
  `product_review_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL CHECK (`rating` between 1 and 5),
  `title` varchar(150) DEFAULT NULL,
  `content` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `approved` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product_reviews`
--

INSERT INTO `product_reviews` (`product_review_id`, `product_id`, `user_id`, `rating`, `title`, `content`, `created_at`, `approved`) VALUES
(1, 33, 21, 5, 'Chất lượng rất tốt', 'aaaaaaaaaaaaaaaaaa', '2025-12-02 09:11:42', 1);

-- --------------------------------------------------------

--
-- Table structure for table `product_review_replies`
--

CREATE TABLE `product_review_replies` (
  `reply_id` int(11) NOT NULL,
  `product_review_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product_review_replies`
--

INSERT INTO `product_review_replies` (`reply_id`, `product_review_id`, `user_id`, `content`, `created_at`) VALUES
(1, 1, 1, 'ok', '2025-12-02 09:23:09');

-- --------------------------------------------------------

--
-- Table structure for table `provinces`
--

CREATE TABLE `provinces` (
  `province_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `provinces`
--

INSERT INTO `provinces` (`province_id`, `name`) VALUES
(1, 'TP Hà Nội'),
(2, 'TP Huế'),
(3, 'Quảng Ninh'),
(4, 'Cao Bằng'),
(5, 'Lạng Sơn'),
(6, 'Lai Châu'),
(7, 'Điện Biên'),
(8, 'Sơn La'),
(9, 'Thanh Hóa'),
(10, 'Nghệ An'),
(11, 'Hà Tĩnh'),
(12, 'Tuyên Quang'),
(13, 'Lào Cai'),
(14, 'Thái Nguyên'),
(15, 'Phú Thọ'),
(16, 'Bắc Ninh'),
(17, 'Hưng Yên'),
(18, 'TP Hải Phòng'),
(19, 'Ninh Bình'),
(20, 'Quảng Trị'),
(21, 'TP Đà Nẵng'),
(22, 'Quảng Ngãi'),
(23, 'Gia Lai'),
(24, 'Khánh Hòa'),
(25, 'Lâm Đồng'),
(26, 'Đắk Lắk'),
(27, 'TP Hồ Chí Minh'),
(28, 'Đồng Nai'),
(29, 'Tây Ninh'),
(30, 'TP Cần Thơ'),
(31, 'Vĩnh Long'),
(32, 'Đồng Tháp'),
(33, 'Cà Mau'),
(34, 'An Giang');

-- --------------------------------------------------------

--
-- Table structure for table `remember_tokens`
--

CREATE TABLE `remember_tokens` (
  `remember_token_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `expire_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `remember_tokens`
--

INSERT INTO `remember_tokens` (`remember_token_id`, `user_id`, `token`, `expire_at`) VALUES
(1, 21, 'db38ca6c-61e3-40c0-a50f-d9fe2bd02e2b', '2025-12-09 06:46:59'),
(2, 1, '1d591704-e0c3-433c-8edb-004c88016fea', '2025-12-13 03:27:24'),
(3, 1, 'd0059f78-3c6e-47cf-ac22-5a53f413a267', '2025-12-14 05:18:56'),
(4, 1, '586ac9d0-9c52-4d8b-bc6e-42e64db1d855', '2025-12-14 05:19:55');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('user','admin') DEFAULT 'user',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `password_changed_at` timestamp NULL DEFAULT NULL,
  `phoneNumber` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `province_id` int(11) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `tax_code` varchar(50) DEFAULT NULL,
  `tax_email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `full_name`, `email`, `password_hash`, `role`, `created_at`, `password_changed_at`, `phoneNumber`, `address`, `province_id`, `company_name`, `tax_code`, `tax_email`) VALUES
(1, 'Admin One', 'admin1@example.com', '123456', 'admin', '2025-11-10 22:40:19', NULL, '0911000001', NULL, NULL, NULL, NULL, NULL),
(2, 'Admin Two', 'admin2@example.com', '123456', 'admin', '2025-11-10 22:40:19', NULL, '0911000002', NULL, NULL, NULL, NULL, NULL),
(3, 'Admin Three', 'admin3@example.com', '123456', 'admin', '2025-11-10 22:40:19', NULL, '0911000003', NULL, NULL, NULL, NULL, NULL),
(4, 'User Four', 'user4@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000004', NULL, NULL, NULL, NULL, NULL),
(5, 'User Five', 'user5@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000005', NULL, NULL, NULL, NULL, NULL),
(6, 'User Six', 'user6@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000006', NULL, NULL, NULL, NULL, NULL),
(7, 'User Seven', 'user7@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000007', NULL, NULL, NULL, NULL, NULL),
(8, 'User Eight', 'user8@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000008', NULL, NULL, NULL, NULL, NULL),
(9, 'User Nine', 'user9@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000009', NULL, NULL, NULL, NULL, NULL),
(10, 'User Ten', 'user10@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000010', NULL, NULL, NULL, NULL, NULL),
(11, 'User Eleven', 'user11@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000011', NULL, NULL, NULL, NULL, NULL),
(12, 'User Twelve', 'user12@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000012', NULL, NULL, NULL, NULL, NULL),
(13, 'User Thirteen', 'user13@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000013', NULL, NULL, NULL, NULL, NULL),
(14, 'User Fourteen', 'user14@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000014', NULL, NULL, NULL, NULL, NULL),
(15, 'User Fifteen', 'user15@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000015', NULL, NULL, NULL, NULL, NULL),
(16, 'User Sixteen', 'user16@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000016', NULL, NULL, NULL, NULL, NULL),
(17, 'User Seventeen', 'user17@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000017', NULL, NULL, NULL, NULL, NULL),
(18, 'User Eighteen', 'user18@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000018', NULL, NULL, NULL, NULL, NULL),
(19, 'User Nineteen', 'user19@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000019', NULL, NULL, NULL, NULL, NULL),
(20, 'User Twenty', 'user20@example.com', '123456', 'user', '2025-11-10 22:40:19', NULL, '0911000020', NULL, NULL, NULL, NULL, NULL),
(21, 'Tranh', 'lopa59733@gmail.com', '123456', 'user', '2025-11-11 12:21:45', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(22, 'Nguyễn Minh Quân', 'quan@example.com', '123456', 'admin', '2025-11-01 20:57:23', NULL, '0912345678', NULL, NULL, NULL, NULL, NULL),
(23, 'Lê Thị Hòa', 'hoa@example.com', '123456', 'user', '2025-11-01 20:57:23', NULL, '0987654321', NULL, NULL, NULL, NULL, NULL),
(24, 'Phạm Anh Núi', 'duy@example.com', '123456', 'user', '2025-11-01 20:57:23', NULL, '0901122334', NULL, NULL, NULL, NULL, NULL),
(25, 'Phạm Anh Duy', 'a@example.com', '123456', 'user', '2025-11-10 08:08:10', NULL, '123456123930', NULL, NULL, NULL, NULL, NULL),
(26, 'clone', 'biennguyen6304@gmail.com', '123456', 'user', '2025-11-24 19:21:19', NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_revenue_delivered`
-- (See below for the actual view)
--
CREATE TABLE `v_revenue_delivered` (
`order_id` int(11)
,`user_id` int(11)
,`total_price` decimal(10,2)
,`tax` decimal(10,2)
,`discount_amount` decimal(10,2)
,`shipping_fee` decimal(10,2)
,`net_without_tax_shipping` decimal(13,2)
,`status` enum('Chờ duyệt','Đang giao','Đã giao','Đã hủy')
,`payment_status` enum('pending','paid','refunded','failed')
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Structure for view `v_revenue_delivered`
--
DROP TABLE IF EXISTS `v_revenue_delivered`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_revenue_delivered`  AS SELECT `o`.`order_id` AS `order_id`, `o`.`user_id` AS `user_id`, `o`.`total_price` AS `total_price`, `o`.`tax` AS `tax`, `o`.`discount_amount` AS `discount_amount`, `o`.`shipping_fee` AS `shipping_fee`, `o`.`total_price`- `o`.`tax` - `o`.`shipping_fee` + `o`.`discount_amount` AS `net_without_tax_shipping`, `o`.`status` AS `status`, `o`.`payment_status` AS `payment_status`, `o`.`created_at` AS `created_at` FROM `orders` AS `o` WHERE `o`.`status` = 'Đã giao' ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`),
  ADD KEY `parent_id` (`parent_id`);

--
-- Indexes for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`chat_message_id`),
  ADD KEY `idx_chat_user_created` (`user_id`,`created_at`),
  ADD KEY `idx_chat_created` (`created_at`);

--
-- Indexes for table `coupons`
--
ALTER TABLE `coupons`
  ADD PRIMARY KEY (`coupon_id`),
  ADD UNIQUE KEY `uq_coupons_code` (`code`),
  ADD KEY `idx_coupons_active_window` (`active`,`start_at`,`end_at`);

--
-- Indexes for table `emailotp`
--
ALTER TABLE `emailotp`
  ADD PRIMARY KEY (`otp_id`),
  ADD UNIQUE KEY `uniq_email` (`email`(50)),
  ADD KEY `idx_emailotp_expire` (`expire_at`);

--
-- Indexes for table `feedback`
--
ALTER TABLE `feedback`
  ADD PRIMARY KEY (`feedback_id`);

--
-- Indexes for table `inventory_movements`
--
ALTER TABLE `inventory_movements`
  ADD PRIMARY KEY (`inventory_movement_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `order_detail_id` (`order_detail_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `payment_id` (`payment_id`),
  ADD KEY `province_id` (`province_id`),
  ADD KEY `idx_orders_user_status` (`user_id`,`status`),
  ADD KEY `idx_orders_status` (`status`),
  ADD KEY `idx_orders_created` (`created_at`),
  ADD KEY `idx_orders_coupon` (`coupon_code`);

--
-- Indexes for table `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`order_detail_id`),
  ADD UNIQUE KEY `uq_order_product` (`order_id`,`product_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `order_history`
--
ALTER TABLE `order_history`
  ADD PRIMARY KEY (`order_history_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `idx_order_history_changed_by` (`changed_by`);

--
-- Indexes for table `order_shipments`
--
ALTER TABLE `order_shipments`
  ADD PRIMARY KEY (`order_shipment_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`password_reset_id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `fk_password_resets_user` (`user_id`);

--
-- Indexes for table `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD PRIMARY KEY (`payment_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `idx_products_category_price` (`category_id`,`price`);
ALTER TABLE `products` ADD FULLTEXT KEY `ft_products_name_desc` (`name`,`description`);

--
-- Indexes for table `product_price_history`
--
ALTER TABLE `product_price_history`
  ADD PRIMARY KEY (`product_price_history_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD PRIMARY KEY (`product_review_id`),
  ADD UNIQUE KEY `uq_review_product_user` (`product_id`,`user_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `product_review_replies`
--
ALTER TABLE `product_review_replies`
  ADD PRIMARY KEY (`reply_id`),
  ADD KEY `product_review_id` (`product_review_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `provinces`
--
ALTER TABLE `provinces`
  ADD PRIMARY KEY (`province_id`);

--
-- Indexes for table `remember_tokens`
--
ALTER TABLE `remember_tokens`
  ADD PRIMARY KEY (`remember_token_id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `fk_remember_tokens_user` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `uq_users_email` (`email`),
  ADD KEY `idx_users_phone` (`phoneNumber`),
  ADD KEY `fk_users_province` (`province_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `chat_message_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `coupons`
--
ALTER TABLE `coupons`
  MODIFY `coupon_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `emailotp`
--
ALTER TABLE `emailotp`
  MODIFY `otp_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `feedback`
--
ALTER TABLE `feedback`
  MODIFY `feedback_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `inventory_movements`
--
ALTER TABLE `inventory_movements`
  MODIFY `inventory_movement_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `order_details`
--
ALTER TABLE `order_details`
  MODIFY `order_detail_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `order_history`
--
ALTER TABLE `order_history`
  MODIFY `order_history_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `order_shipments`
--
ALTER TABLE `order_shipments`
  MODIFY `order_shipment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `password_reset_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `payment_methods`
--
ALTER TABLE `payment_methods`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `product_price_history`
--
ALTER TABLE `product_price_history`
  MODIFY `product_price_history_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_reviews`
--
ALTER TABLE `product_reviews`
  MODIFY `product_review_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `product_review_replies`
--
ALTER TABLE `product_review_replies`
  MODIFY `reply_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `provinces`
--
ALTER TABLE `provinces`
  MODIFY `province_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `remember_tokens`
--
ALTER TABLE `remember_tokens`
  MODIFY `remember_token_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `fk_categories_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL;

--
-- Constraints for table `inventory_movements`
--
ALTER TABLE `inventory_movements`
  ADD CONSTRAINT `fk_inv_mov_order_detail` FOREIGN KEY (`order_detail_id`) REFERENCES `order_details` (`order_detail_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_inv_mov_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_coupon` FOREIGN KEY (`coupon_code`) REFERENCES `coupons` (`code`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_orders_payment` FOREIGN KEY (`payment_id`) REFERENCES `payment_methods` (`payment_id`),
  ADD CONSTRAINT `fk_orders_province` FOREIGN KEY (`province_id`) REFERENCES `provinces` (`province_id`),
  ADD CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `fk_order_details_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_order_details_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`);

--
-- Constraints for table `order_history`
--
ALTER TABLE `order_history`
  ADD CONSTRAINT `fk_order_history_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_order_history_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `order_shipments`
--
ALTER TABLE `order_shipments`
  ADD CONSTRAINT `fk_order_shipments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE;

--
-- Constraints for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD CONSTRAINT `fk_password_resets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`);

--
-- Constraints for table `product_price_history`
--
ALTER TABLE `product_price_history`
  ADD CONSTRAINT `fk_price_history_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Constraints for table `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD CONSTRAINT `fk_reviews_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `product_review_replies`
--
ALTER TABLE `product_review_replies`
  ADD CONSTRAINT `fk_review_replies_review` FOREIGN KEY (`product_review_id`) REFERENCES `product_reviews` (`product_review_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_review_replies_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `remember_tokens`
--
ALTER TABLE `remember_tokens`
  ADD CONSTRAINT `fk_remember_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_province` FOREIGN KEY (`province_id`) REFERENCES `provinces` (`province_id`) ON DELETE SET NULL ON UPDATE CASCADE;

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `ev_cleanup_expired_tokens` ON SCHEDULE EVERY 1 DAY STARTS '2025-11-16 11:30:41' ON COMPLETION NOT PRESERVE ENABLE DO CALL cleanup_expired_data()$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
