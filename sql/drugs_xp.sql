CREATE TABLE IF NOT EXISTS `player_drug_xp` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `xp` INT DEFAULT 0,
    `level` INT DEFAULT 1,
    `total_sales` INT DEFAULT 0,
    `weed_sold` INT DEFAULT 0,
    `cocaine_sold` INT DEFAULT 0,
    `meth_sold` INT DEFAULT 0,
    `crack_sold` INT DEFAULT 0,
    `moonshine_sold` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `unique_citizenid` (`citizenid`),
    INDEX `idx_drug_xp_level` (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
