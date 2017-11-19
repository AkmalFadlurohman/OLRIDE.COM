SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `driver`;
DROP TABLE IF EXISTS `driver_prefloc`;
DROP TABLE IF EXISTS `order`;
SET FOREIGN_KEY_CHECKS = 1;



CREATE TABLE IF NOT EXISTS `driver_prefloc` (
	`driver_id`   INT         NOT NULL,
    `pref_loc`    VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `order` (
	`order_id`       INT            NOT NULL  AUTO_INCREMENT,
	`dest_city`     VARCHAR(50)     NOT NULL,
	`pick_city`     VARCHAR(50)     NOT NULL,
    `score`         DOUBLE(50,1)    NOT NULL,
    `comment`       VARCHAR(140)    NOT NULL,
    `driver_id`     INT             NOT NULL,
    `cust_id`       INT             NOT NULL,
    `date`          DATE            NOT NULL,
    `customer_visibility`    VARCHAR(10)     NOT NULL,
	`driver_visibility`    VARCHAR(10)     NOT NULL,

	PRIMARY KEY (`order_id`)
) ENGINE=InnoDB;
