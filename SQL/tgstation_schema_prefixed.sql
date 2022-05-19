/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP TABLE IF EXISTS `SS13_achievements`;
CREATE TABLE IF NOT EXISTS `SS13_achievements` (
  `name` mediumtext NOT NULL,
  `id` int(10) unsigned NOT NULL,
  `descr` varchar(2048) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_admin`;
CREATE TABLE IF NOT EXISTS `SS13_admin` (
  `ckey` varchar(32) NOT NULL,
  `rank` varchar(32) NOT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_admin_log`;
CREATE TABLE IF NOT EXISTS `SS13_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(10) unsigned NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `adminip` int(10) unsigned NOT NULL,
  `operation` enum('add admin','remove admin','change admin rank','add rank','remove rank','change rank flags', 'add mentor') NOT NULL,
  `target` varchar(32) NOT NULL,
  `log` varchar(1000) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=342 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_admin_ranks`;
CREATE TABLE IF NOT EXISTS `SS13_admin_ranks` (
  `rank` varchar(32) NOT NULL,
  `flags` smallint(5) unsigned NOT NULL,
  `exclude_flags` smallint(5) unsigned NOT NULL,
  `can_edit_flags` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `ss13_admin_tickets`;
CREATE TABLE IF NOT EXISTS `ss13_admin_tickets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `round_id` int(10) unsigned NOT NULL DEFAULT 0,
  `ticket_id` int(10) unsigned NOT NULL DEFAULT 0,
  `when` datetime NOT NULL DEFAULT current_timestamp(),
  `ckey` varchar(32) NOT NULL,
  `a_ckey` varchar(32),
  PRIMARY KEY (`id`),
  KEY `idx_round` (`round_id`),
  KEY `idx_round_ticket` (`round_id`,`ticket_id`)
) ENGINE=InnoDB AUTO_INCREMENT=157319 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `ss13_admin_ticket_interactions`;
CREATE TABLE IF NOT EXISTS `ss13_admin_ticket_content` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` int(10) unsigned,
  `when` datetime NOT NULL DEFAULT current_timestamp(),
  `user` varchar(32) NOT NULL,
  `text` text,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`ticket_id`) REFERENCES `ss13_admin_tickets`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_antag_tokens`;
CREATE TABLE IF NOT EXISTS `SS13_antag_tokens` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `reason` varchar(2048) NOT NULL,
  `denial_reason` varchar(2048) DEFAULT NULL,
  `applying_admin` varchar(32) NOT NULL,
  `denying_admin` varchar(32) DEFAULT NULL,
  `granted_time` datetime NOT NULL,
  `redeemed` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `round_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=273 DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `SS13_ban`;
CREATE TABLE IF NOT EXISTS `SS13_ban` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(10) unsigned NOT NULL,
  `role` varchar(32) DEFAULT NULL,
  `expiration_time` datetime DEFAULT NULL,
  `applies_to_admins` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `reason` varchar(2048) NOT NULL,
  `ckey` varchar(32) DEFAULT NULL,
  `ip` int(10) unsigned DEFAULT NULL,
  `computerid` varchar(32) DEFAULT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_ip` int(10) unsigned NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `who` varchar(2048) NOT NULL,
  `adminwho` varchar(2048) NOT NULL,
  `edits` mediumtext DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_ip` int(10) unsigned DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_round_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ban_isbanned` (`ckey`,`role`,`unbanned_datetime`,`expiration_time`),
  KEY `idx_ban_isbanned_details` (`ckey`,`ip`,`computerid`,`role`,`unbanned_datetime`,`expiration_time`),
  KEY `idx_ban_count` (`bantime`,`a_ckey`,`applies_to_admins`,`unbanned_datetime`,`expiration_time`)
) ENGINE=InnoDB AUTO_INCREMENT=39587 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SS13_bound_credentials`;
CREATE TABLE `SS13_bound_credentials` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `computerid` varchar(32) DEFAULT NULL,
  `ip` int(10) unsigned DEFAULT NULL,
  `flags` set('bypass_bans') DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ckey_lookup` (`ckey`),
  KEY `idx_cid_lookup` (`computerid`),
  KEY `idx_ip_lookup` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SS13_connection_log`;
CREATE TABLE IF NOT EXISTS `SS13_connection_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime DEFAULT NULL,
  `left` datetime DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(10) unsigned NOT NULL,
  `ckey` varchar(45) DEFAULT NULL,
  `ip` int(10) unsigned NOT NULL,
  `computerid` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_review` (`ckey`, `computerid`, `ip`)
) ENGINE=InnoDB AUTO_INCREMENT=4192042 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_death`;
CREATE TABLE IF NOT EXISTS `SS13_death` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pod` varchar(50) NOT NULL,
  `x_coord` smallint(5) unsigned NOT NULL,
  `y_coord` smallint(5) unsigned NOT NULL,
  `z_coord` smallint(5) unsigned NOT NULL,
  `mapname` varchar(32) NOT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) NOT NULL,
  `tod` datetime NOT NULL COMMENT 'Time of death',
  `job` varchar(32) NOT NULL,
  `special` varchar(32) DEFAULT NULL,
  `name` varchar(96) NOT NULL,
  `byondkey` varchar(32) NOT NULL,
  `laname` varchar(96) DEFAULT NULL,
  `lakey` varchar(32) DEFAULT NULL,
  `bruteloss` smallint(5) unsigned NOT NULL,
  `brainloss` smallint(5) unsigned NOT NULL,
  `fireloss` smallint(5) unsigned NOT NULL,
  `oxyloss` smallint(5) unsigned NOT NULL,
  `toxloss` smallint(5) unsigned NOT NULL,
  `cloneloss` smallint(5) unsigned NOT NULL,
  `staminaloss` smallint(5) unsigned NOT NULL,
  `last_words` varchar(255) DEFAULT NULL,
  `suicide` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1422836 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_donors`;
CREATE TABLE IF NOT EXISTS `SS13_donors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `discord_id` varchar(32) DEFAULT NULL,
  `transaction_id` varchar(70) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `datetime` timestamp NOT NULL DEFAULT current_timestamp(),
  `expiration_time` datetime DEFAULT NULL,
  `revoked` int(11) DEFAULT NULL,
  `revoked_ckey` varchar(32) DEFAULT NULL,
  `revoked_time` datetime DEFAULT NULL,
  `payer_email` varchar(256) DEFAULT NULL,
  `status` varchar(32) NOT NULL,
  `notes` varchar(1024) DEFAULT NULL,
  `valid` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `ckey` (`ckey`),
  KEY `forum_username` (`discord_id`)
) ENGINE=InnoDB AUTO_INCREMENT=761 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_earned_achievements`;
CREATE TABLE IF NOT EXISTS `SS13_earned_achievements` (
  `ckey` varchar(32) NOT NULL,
  `id` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_feedback`;
CREATE TABLE IF NOT EXISTS `SS13_feedback` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(10) unsigned NOT NULL,
  `key_name` varchar(32) NOT NULL,
  `key_type` enum('text','amount','tally','nested tally','associative') NOT NULL,
  `version` tinyint(3) unsigned NOT NULL,
  `json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`json`)),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=349150 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_feedback_normalized`;
CREATE TABLE IF NOT EXISTS `SS13_feedback_normalized` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(10) unsigned NOT NULL,
  `category_primary` text NOT NULL DEFAULT '',
  `category_secondary` text NOT NULL DEFAULT '',
  `category_tertiary` text NOT NULL DEFAULT '',
  `version` tinyint(3) unsigned NOT NULL,
  `data` longtext NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6204920 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_ipintel`;
CREATE TABLE IF NOT EXISTS `SS13_ipintel` (
  `ip` int(10) unsigned NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `intel` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`ip`),
  KEY `idx_ipintel` (`ip`,`intel`,`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_legacy_population`;
CREATE TABLE IF NOT EXISTS `SS13_legacy_population` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playercount` int(11) DEFAULT NULL,
  `admincount` int(11) DEFAULT NULL,
  `time` datetime NOT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=490160 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_library`;
CREATE TABLE IF NOT EXISTS `SS13_library` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` varchar(45) NOT NULL,
  `title` varchar(45) NOT NULL,
  `content` mediumtext NOT NULL,
  `category` enum('Any','Fiction','Non-Fiction','Adult','Reference','Religion') NOT NULL,
  `ckey` varchar(32) NOT NULL DEFAULT 'LEGACY',
  `datetime` datetime NOT NULL,
  `deleted` tinyint(3) unsigned DEFAULT NULL,
  `round_id_created` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `deleted_idx` (`deleted`),
  KEY `idx_lib_id_del` (`id`,`deleted`),
  KEY `idx_lib_del_title` (`deleted`,`title`),
  KEY `idx_lib_search` (`deleted`,`author`,`title`,`category`)
) ENGINE=InnoDB AUTO_INCREMENT=2017 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_loa`;
CREATE TABLE IF NOT EXISTS `SS13_loa` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `time` date NOT NULL,
  `expiry_time` date NOT NULL,
  `revoked` bit(1) DEFAULT NULL,
  `reason` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=419 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_mentor`;
CREATE TABLE IF NOT EXISTS `SS13_mentor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `position` varchar(32) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_mentor_memo`;
CREATE TABLE IF NOT EXISTS `SS13_mentor_memo` (
  `ckey` varchar(32) NOT NULL,
  `memotext` mediumtext NOT NULL,
  `timestamp` datetime NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` mediumtext DEFAULT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_messages`;
CREATE TABLE IF NOT EXISTS `SS13_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(32) NOT NULL,
  `targetckey` varchar(32) NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `text` mediumtext NOT NULL,
  `timestamp` datetime NOT NULL,
  `server` varchar(32) DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(10) unsigned NOT NULL,
  `secret` tinyint(1) DEFAULT 1,
  `expire_timestamp` datetime DEFAULT NULL,
  `lasteditor` varchar(32) DEFAULT NULL,
  `edits` mediumtext DEFAULT NULL,
  `deleted` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_msg_ckey_time` (`targetckey`,`timestamp`,`deleted`),
  KEY `idx_msg_type_ckeys_time` (`type`,`targetckey`,`adminckey`,`timestamp`,`deleted`),
  KEY `idx_msg_type_ckey_time_odr` (`type`,`targetckey`,`timestamp`,`deleted`)
) ENGINE=InnoDB AUTO_INCREMENT=75629 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SS13_mfa_logins`;
CREATE TABLE IF NOT EXISTS `SS13_mfa_logins` (
	`ckey` varchar(32) NOT NULL,
	`ip` int(10) unsigned NOT NULL,
	`cid` varchar(32) NOT NULL,
	`datetime` timestamp NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`ckey`,`ip`,`cid`,`datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SS13_misc`;
CREATE TABLE IF NOT EXISTS `SS13_misc` (
  `key` varchar(32) NOT NULL,
  `value` varchar(2048) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_player`;
CREATE TABLE IF NOT EXISTS `SS13_player` (
  `ckey` varchar(32) NOT NULL,
  `byond_key` varchar(32) DEFAULT NULL,
  `firstseen` datetime NOT NULL,
  `firstseen_round_id` int(10) unsigned NOT NULL,
  `lastseen` datetime NOT NULL,
  `lastseen_round_id` int(10) unsigned NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `lastadminrank` varchar(32) NOT NULL DEFAULT 'Player',
  `accountjoindate` date DEFAULT NULL,
  `flags` int(11) NOT NULL DEFAULT 0,
  `discord_id` bigint(20) DEFAULT NULL,
  `antag_tokens` int(10) unsigned NOT NULL DEFAULT 0,
  `credits` bigint(20) unsigned NOT NULL DEFAULT 0,
  `antag_weight` mediumint(8) unsigned NOT NULL DEFAULT 100,
  `job_whitelisted` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `totp_seed` varchar(20),
  `mfa_backup` varchar(128),
  PRIMARY KEY (`ckey`),
  KEY `idx_player_cid_ckey` (`computerid`,`ckey`),
  KEY `idx_player_ip_ckey` (`ip`,`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_poll_option`;
CREATE TABLE IF NOT EXISTS `SS13_poll_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pollid` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `minval` int(11) DEFAULT NULL,
  `maxval` int(11) DEFAULT NULL,
  `descmin` varchar(32) DEFAULT NULL,
  `descmid` varchar(32) DEFAULT NULL,
  `descmax` varchar(32) DEFAULT NULL,
  `default_percentage_calc` tinyint(3) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `idx_pop_pollid` (`pollid`)
) ENGINE=InnoDB AUTO_INCREMENT=272 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_poll_question`;
CREATE TABLE IF NOT EXISTS `SS13_poll_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `polltype` enum('OPTION','TEXT','NUMVAL','MULTICHOICE','IRV') NOT NULL,
  `starttime` datetime NOT NULL,
  `endtime` datetime NOT NULL,
  `question` varchar(255) NOT NULL,
  `adminonly` tinyint(3) unsigned NOT NULL,
  `multiplechoiceoptions` int(11) DEFAULT NULL,
  `createdby_ckey` varchar(32) DEFAULT NULL,
  `createdby_ip` int(10) unsigned NOT NULL,
  `dontshow` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_pquest_question_time_ckey` (`question`,`starttime`,`endtime`,`createdby_ckey`,`createdby_ip`),
  KEY `idx_pquest_time_admin` (`starttime`,`endtime`,`adminonly`),
  KEY `idx_pquest_id_time_type_admin` (`id`,`starttime`,`endtime`,`polltype`,`adminonly`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_poll_textreply`;
CREATE TABLE IF NOT EXISTS `SS13_poll_textreply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `replytext` varchar(2048) NOT NULL,
  `adminrank` varchar(32) NOT NULL DEFAULT 'Player',
  PRIMARY KEY (`id`),
  KEY `idx_ptext_pollid_ckey` (`pollid`,`ckey`)
) ENGINE=InnoDB AUTO_INCREMENT=365 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_poll_vote`;
CREATE TABLE IF NOT EXISTS `SS13_poll_vote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `optionid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `adminrank` varchar(32) NOT NULL,
  `rating` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_pvote_pollid_ckey` (`pollid`,`ckey`),
  KEY `idx_pvote_optionid_ckey` (`optionid`,`ckey`)
) ENGINE=InnoDB AUTO_INCREMENT=12987 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_role_time`;
CREATE TABLE IF NOT EXISTS `SS13_role_time` (
  `ckey` varchar(32) NOT NULL,
  `job` varchar(128) NOT NULL,
  `minutes` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ckey`,`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_role_time_log`;
CREATE TABLE IF NOT EXISTS `SS13_role_time_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `job` varchar(128) NOT NULL,
  `delta` int(11) NOT NULL,
  `datetime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`),
  KEY `job` (`job`),
  KEY `datetime` (`datetime`)
) ENGINE=InnoDB AUTO_INCREMENT=7175905 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_round`;
CREATE TABLE IF NOT EXISTS `SS13_round` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `initialize_datetime` datetime NOT NULL,
  `start_datetime` datetime DEFAULT NULL,
  `shutdown_datetime` datetime DEFAULT NULL,
  `end_datetime` datetime DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `commit_hash` char(40) DEFAULT NULL,
  `game_mode` varchar(32) DEFAULT NULL,
  `game_mode_result` varchar(64) DEFAULT NULL,
  `end_state` varchar(64) DEFAULT NULL,
  `shuttle_name` varchar(64) DEFAULT NULL,
  `map_name` varchar(32) DEFAULT NULL,
  `station_name` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32366 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_schema_revision`;
CREATE TABLE IF NOT EXISTS `SS13_schema_revision` (
  `major` tinyint(3) unsigned NOT NULL,
  `minor` tinyint(3) unsigned NOT NULL,
  `date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`major`,`minor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_stickyban`;
CREATE TABLE IF NOT EXISTS `SS13_stickyban` (
  `ckey` varchar(32) NOT NULL,
  `reason` varchar(2048) NOT NULL,
  `banning_admin` varchar(32) NOT NULL,
  `datetime` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_stickyban_matched_cid`;
CREATE TABLE IF NOT EXISTS `SS13_stickyban_matched_cid` (
  `stickyban` varchar(32) NOT NULL,
  `matched_cid` varchar(32) NOT NULL,
  `first_matched` datetime NOT NULL DEFAULT current_timestamp(),
  `last_matched` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`stickyban`,`matched_cid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_stickyban_matched_ckey`;
CREATE TABLE IF NOT EXISTS `SS13_stickyban_matched_ckey` (
  `stickyban` varchar(32) NOT NULL,
  `matched_ckey` varchar(32) NOT NULL,
  `first_matched` datetime NOT NULL DEFAULT current_timestamp(),
  `last_matched` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `exempt` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`stickyban`,`matched_ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SS13_stickyban_matched_ip`;
CREATE TABLE IF NOT EXISTS `SS13_stickyban_matched_ip` (
  `stickyban` varchar(32) NOT NULL,
  `matched_ip` int(10) unsigned NOT NULL,
  `first_matched` datetime NOT NULL DEFAULT current_timestamp(),
  `last_matched` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`stickyban`,`matched_ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Dumping structure for trigger yogstation_copy.role_timeTlogdelete
DROP TRIGGER IF EXISTS `role_timeTlogdelete`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `role_timeTlogdelete` AFTER DELETE ON `SS13_role_time` FOR EACH ROW BEGIN INSERT into SS13_role_time_log (ckey, job, delta) VALUES (OLD.ckey, OLD.job, 0-OLD.minutes);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger yogstation_copy.role_timeTloginsert
DROP TRIGGER IF EXISTS `role_timeTloginsert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `role_timeTloginsert` AFTER INSERT ON `SS13_role_time` FOR EACH ROW BEGIN INSERT into SS13_role_time_log (ckey, job, delta) VALUES (NEW.ckey, NEW.job, NEW.minutes);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger yogstation_copy.role_timeTlogupdate
DROP TRIGGER IF EXISTS `role_timeTlogupdate`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `role_timeTlogupdate` AFTER UPDATE ON `SS13_role_time` FOR EACH ROW BEGIN INSERT into SS13_role_time_log (ckey, job, delta) VALUES (NEW.CKEY, NEW.job, NEW.minutes-OLD.minutes);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
