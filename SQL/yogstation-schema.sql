/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Table: erro_achievements
CREATE TABLE IF NOT EXISTS `erro_achievements` (
  `name` varchar(32) NOT NULL,
  `id` int(10) unsigned NOT NULL,
  `descr` varchar(2048) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_admin
CREATE TABLE IF NOT EXISTS `erro_admin` (
  `ckey` varchar(32) NOT NULL,
  `rank` varchar(32) NOT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_admin_log
CREATE TABLE IF NOT EXISTS `erro_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(10) unsigned NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `adminip` int(10) unsigned NOT NULL,
  `operation` enum('add admin','remove admin','change admin rank','add rank','remove rank','change rank flags') NOT NULL,
  `target` varchar(32) NOT NULL,
  `log` varchar(1000) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=145 DEFAULT CHARSET=utf8;

-- Table: erro_admin_ranks
CREATE TABLE IF NOT EXISTS `erro_admin_ranks` (
  `rank` varchar(32) NOT NULL,
  `flags` smallint(5) unsigned NOT NULL,
  `exclude_flags` smallint(5) unsigned NOT NULL,
  `can_edit_flags` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_admin_tickets
CREATE TABLE IF NOT EXISTS `erro_admin_tickets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `round_id` int(10) unsigned NOT NULL DEFAULT '0',
  `ticket_id` int(10) unsigned NOT NULL DEFAULT '0',
  `when` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ckey` varchar(32) NOT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `content` text NOT NULL,
  `rating` tinyint(2) unsigned NOT NULL DEFAULT '5',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=157319 DEFAULT CHARSET=utf8;

-- Table: erro_ban
CREATE TABLE IF NOT EXISTS `erro_ban` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `role` varchar(32) DEFAULT NULL,
  `expiration_time` datetime DEFAULT NULL,
  `applies_to_admins` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `reason` varchar(2048) NOT NULL,
  `ckey` varchar(32) DEFAULT NULL,
  `ip` int(10) unsigned DEFAULT NULL,
  `computerid` varchar(32) DEFAULT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_ip` int(10) unsigned NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `who` varchar(2048) NOT NULL,
  `adminwho` varchar(2048) NOT NULL,
  `edits` mediumtext,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_ip` int(10) unsigned DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_round_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ban_isbanned` (`ckey`,`role`,`unbanned_datetime`,`expiration_time`),
  KEY `idx_ban_isbanned_details` (`ckey`,`ip`,`computerid`,`role`,`unbanned_datetime`,`expiration_time`),
  KEY `idx_ban_count` (`bantime`,`a_ckey`,`applies_to_admins`,`unbanned_datetime`,`expiration_time`)
) ENGINE=InnoDB AUTO_INCREMENT=36539 DEFAULT CHARSET=utf8;

-- Table: erro_ban_old
CREATE TABLE IF NOT EXISTS `erro_ban_old` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) NOT NULL,
  `bantype` enum('PERMABAN','TEMPBAN','JOB_PERMABAN','JOB_TEMPBAN','ADMIN_PERMABAN','ADMIN_TEMPBAN') NOT NULL,
  `reason` varchar(2048) NOT NULL,
  `job` varchar(32) DEFAULT NULL,
  `duration` int(11) NOT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `a_ip` int(10) unsigned NOT NULL,
  `who` varchar(2048) NOT NULL,
  `adminwho` varchar(2048) NOT NULL,
  `edits` mediumtext,
  `unbanned` tinyint(3) unsigned DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_ip` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ban_checkban` (`ckey`,`bantype`,`expiration_time`,`unbanned`,`job`),
  KEY `idx_ban_isbanned` (`ckey`,`ip`,`computerid`,`bantype`,`expiration_time`,`unbanned`),
  KEY `idx_ban_count` (`id`,`a_ckey`,`bantype`,`expiration_time`,`unbanned`)
) ENGINE=InnoDB AUTO_INCREMENT=26832 DEFAULT CHARSET=utf8;

-- Table: erro_connection_log
CREATE TABLE IF NOT EXISTS `erro_connection_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime DEFAULT NULL,
  `left` datetime DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `ckey` varchar(45) DEFAULT NULL,
  `ip` int(10) unsigned NOT NULL,
  `computerid` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3930897 DEFAULT CHARSET=utf8;

-- Table: erro_connection_log_bk20160316
CREATE TABLE IF NOT EXISTS `erro_connection_log_bk20160316` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime DEFAULT NULL,
  `left` datetime DEFAULT NULL,
  `serverip` varchar(45) DEFAULT NULL,
  `ckey` varchar(45) DEFAULT NULL,
  `ip` varchar(18) DEFAULT NULL,
  `computerid` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1078109 DEFAULT CHARSET=utf8;

-- Table: erro_connection_log_bk20190902_1
CREATE TABLE IF NOT EXISTS `erro_connection_log_bk20190902_1` (
  `id` int(11) NOT NULL DEFAULT '0',
  `datetime` datetime DEFAULT NULL,
  `left` datetime DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `ckey` varchar(45) DEFAULT NULL,
  `ip` int(10) unsigned NOT NULL,
  `computerid` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Table: erro_connection_log_oldlmao
CREATE TABLE IF NOT EXISTS `erro_connection_log_oldlmao` (
  `id` int(11) NOT NULL DEFAULT '0',
  `datetime` datetime DEFAULT NULL,
  `left` datetime DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `ckey` varchar(45) DEFAULT NULL,
  `ip` int(10) unsigned NOT NULL,
  `computerid` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Table: erro_death
CREATE TABLE IF NOT EXISTS `erro_death` (
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
  `suicide` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1352217 DEFAULT CHARSET=utf8;

-- Table: erro_donors
CREATE TABLE IF NOT EXISTS `erro_donors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `discord_id` varchar(32) DEFAULT NULL,
  `transaction_id` varchar(70) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `datetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expiration_time` datetime NOT NULL,
  `revoked` int(2) DEFAULT NULL,
  `revoked_ckey` varchar(32) DEFAULT NULL,
  `revoked_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `ckey` (`ckey`),
  KEY `forum_username` (`discord_id`)
) ENGINE=InnoDB AUTO_INCREMENT=681 DEFAULT CHARSET=utf8;

-- Table: erro_earned_achievements
CREATE TABLE IF NOT EXISTS `erro_earned_achievements` (
  `ckey` varchar(32) NOT NULL,
  `id` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_feedback
CREATE TABLE IF NOT EXISTS `erro_feedback` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `key_name` varchar(32) NOT NULL,
  `key_type` enum('text','amount','tally','nested tally','associative') NOT NULL,
  `version` tinyint(3) unsigned NOT NULL,
  `json` json NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=211918 DEFAULT CHARSET=utf8;

-- Table: erro_feedback_normalized
CREATE TABLE IF NOT EXISTS `erro_feedback_normalized` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `category_primary` varchar(255) NOT NULL,
  `category_secondary` varchar(255) NOT NULL,
  `category_tertiary` varchar(255) NOT NULL,
  `version` tinyint(3) unsigned NOT NULL,
  `data` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2368648 DEFAULT CHARSET=utf8;

-- Table: erro_ipintel
CREATE TABLE IF NOT EXISTS `erro_ipintel` (
  `ip` int(10) unsigned NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `intel` double NOT NULL DEFAULT '0',
  PRIMARY KEY (`ip`),
  KEY `idx_ipintel` (`ip`,`intel`,`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_legacy_population
CREATE TABLE IF NOT EXISTS `erro_legacy_population` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playercount` int(11) DEFAULT NULL,
  `admincount` int(11) DEFAULT NULL,
  `time` datetime NOT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=469810 DEFAULT CHARSET=utf8;

-- Table: erro_library
CREATE TABLE IF NOT EXISTS `erro_library` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` varchar(45) NOT NULL,
  `title` varchar(45) NOT NULL,
  `content` mediumtext NOT NULL,
  `category` enum('Any','Fiction','Non-Fiction','Adult','Reference','Religion') NOT NULL,
  `ckey` varchar(32) NOT NULL DEFAULT 'LEGACY',
  `datetime` datetime NOT NULL,
  `deleted` tinyint(1) unsigned DEFAULT NULL,
  `round_id_created` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `deleted_idx` (`deleted`),
  KEY `idx_lib_id_del` (`id`,`deleted`),
  KEY `idx_lib_del_title` (`deleted`,`title`),
  KEY `idx_lib_search` (`deleted`,`author`,`title`,`category`)
) ENGINE=InnoDB AUTO_INCREMENT=1947 DEFAULT CHARSET=utf8;

-- Table: erro_loa
CREATE TABLE IF NOT EXISTS `erro_loa` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `time` date NOT NULL,
  `expiry_time` date NOT NULL,
  `revoked` bit(1) DEFAULT NULL,
  `reason` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=371 DEFAULT CHARSET=utf8;

-- Table: erro_mentor
CREATE TABLE IF NOT EXISTS `erro_mentor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8;

-- Table: erro_mentor_memo
CREATE TABLE IF NOT EXISTS `erro_mentor_memo` (
  `ckey` varchar(32) NOT NULL,
  `memotext` mediumtext NOT NULL,
  `timestamp` datetime NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` mediumtext,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_messages
CREATE TABLE IF NOT EXISTS `erro_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(32) NOT NULL,
  `targetckey` varchar(32) NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `text` mediumtext NOT NULL,
  `timestamp` datetime NOT NULL,
  `server` varchar(32) DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `secret` tinyint(1) DEFAULT '1',
  `expire_timestamp` datetime DEFAULT NULL,
  `lasteditor` varchar(32) DEFAULT NULL,
  `edits` mediumtext,
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_msg_ckey_time` (`targetckey`,`timestamp`,`deleted`),
  KEY `idx_msg_type_ckeys_time` (`type`,`targetckey`,`adminckey`,`timestamp`,`deleted`),
  KEY `idx_msg_type_ckey_time_odr` (`type`,`targetckey`,`timestamp`,`deleted`)
) ENGINE=InnoDB AUTO_INCREMENT=71171 DEFAULT CHARSET=utf8;

-- Table: erro_misc
CREATE TABLE IF NOT EXISTS `erro_misc` (
  `key` varchar(32) NOT NULL,
  `value` varchar(2048) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_notes
CREATE TABLE IF NOT EXISTS `erro_notes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `timestamp` datetime NOT NULL,
  `notetext` mediumtext,
  `adminckey` varchar(32) NOT NULL,
  `server` varchar(32) NOT NULL,
  `secret` tinyint(1) NOT NULL DEFAULT '1',
  `last_editor` varchar(32) NOT NULL DEFAULT '',
  `edits` mediumtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53927 DEFAULT CHARSET=utf8 COMMENT='Notes table';

-- Table: erro_player
CREATE TABLE IF NOT EXISTS `erro_player` (
  `ckey` varchar(32) NOT NULL,
  `byond_key` varchar(32) DEFAULT NULL,
  `firstseen` datetime NOT NULL,
  `firstseen_round_id` int(11) unsigned NOT NULL,
  `lastseen` datetime NOT NULL,
  `lastseen_round_id` int(11) unsigned NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `lastadminrank` varchar(32) NOT NULL DEFAULT 'Player',
  `accountjoindate` date DEFAULT NULL,
  `flags` int(11) NOT NULL DEFAULT '0',
  `discord_id` bigint(20) DEFAULT NULL,
  `antag_tokens` int(2) unsigned NOT NULL DEFAULT '0',
  `credits` bigint(20) unsigned NOT NULL DEFAULT '0',
  `antag_weight` mediumint(5) unsigned NOT NULL DEFAULT '100',
  `job_whitelisted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ckey`),
  KEY `idx_player_cid_ckey` (`computerid`,`ckey`),
  KEY `idx_player_ip_ckey` (`ip`,`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_poll_option
CREATE TABLE IF NOT EXISTS `erro_poll_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pollid` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `minval` int(3) DEFAULT NULL,
  `maxval` int(3) DEFAULT NULL,
  `descmin` varchar(32) DEFAULT NULL,
  `descmid` varchar(32) DEFAULT NULL,
  `descmax` varchar(32) DEFAULT NULL,
  `default_percentage_calc` tinyint(1) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_pop_pollid` (`pollid`)
) ENGINE=InnoDB AUTO_INCREMENT=260 DEFAULT CHARSET=utf8;

-- Table: erro_poll_question
CREATE TABLE IF NOT EXISTS `erro_poll_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `polltype` enum('OPTION','TEXT','NUMVAL','MULTICHOICE','IRV') NOT NULL,
  `starttime` datetime NOT NULL,
  `endtime` datetime NOT NULL,
  `question` varchar(255) NOT NULL,
  `adminonly` tinyint(1) unsigned NOT NULL,
  `multiplechoiceoptions` int(2) DEFAULT NULL,
  `createdby_ckey` varchar(32) DEFAULT NULL,
  `createdby_ip` int(10) unsigned NOT NULL,
  `dontshow` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_pquest_question_time_ckey` (`question`,`starttime`,`endtime`,`createdby_ckey`,`createdby_ip`),
  KEY `idx_pquest_time_admin` (`starttime`,`endtime`,`adminonly`),
  KEY `idx_pquest_id_time_type_admin` (`id`,`starttime`,`endtime`,`polltype`,`adminonly`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8;

-- Table: erro_poll_textreply
CREATE TABLE IF NOT EXISTS `erro_poll_textreply` (
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

-- Table: erro_poll_vote
CREATE TABLE IF NOT EXISTS `erro_poll_vote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `optionid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `adminrank` varchar(32) NOT NULL,
  `rating` int(2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_pvote_pollid_ckey` (`pollid`,`ckey`),
  KEY `idx_pvote_optionid_ckey` (`optionid`,`ckey`)
) ENGINE=InnoDB AUTO_INCREMENT=11993 DEFAULT CHARSET=utf8;

-- Table: erro_privacy
CREATE TABLE IF NOT EXISTS `erro_privacy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `option` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9520 DEFAULT CHARSET=utf8;

-- Table: erro_role_time
CREATE TABLE IF NOT EXISTS `erro_role_time` (
  `ckey` varchar(32) NOT NULL,
  `job` varchar(128) NOT NULL,
  `minutes` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ckey`,`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_role_time_log
CREATE TABLE IF NOT EXISTS `erro_role_time_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `job` varchar(128) NOT NULL,
  `delta` int(11) NOT NULL,
  `datetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`),
  KEY `job` (`job`),
  KEY `datetime` (`datetime`)
) ENGINE=InnoDB AUTO_INCREMENT=5751372 DEFAULT CHARSET=utf8;

-- Table: erro_round
CREATE TABLE IF NOT EXISTS `erro_round` (
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
) ENGINE=InnoDB AUTO_INCREMENT=29713 DEFAULT CHARSET=utf8;

-- Table: erro_schema_revision
CREATE TABLE IF NOT EXISTS `erro_schema_revision` (
  `major` tinyint(3) unsigned NOT NULL,
  `minor` tinyint(3) unsigned NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`major`,`minor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_stickyban
CREATE TABLE IF NOT EXISTS `erro_stickyban` (
  `ckey` varchar(32) NOT NULL,
  `reason` varchar(2048) NOT NULL,
  `banning_admin` varchar(32) NOT NULL,
  `datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_stickyban_matched_cid
CREATE TABLE IF NOT EXISTS `erro_stickyban_matched_cid` (
  `stickyban` varchar(32) NOT NULL,
  `matched_cid` varchar(32) NOT NULL,
  `first_matched` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_matched` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`stickyban`,`matched_cid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_stickyban_matched_ckey
CREATE TABLE IF NOT EXISTS `erro_stickyban_matched_ckey` (
  `stickyban` varchar(32) NOT NULL,
  `matched_ckey` varchar(32) NOT NULL,
  `first_matched` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_matched` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `exempt` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`stickyban`,`matched_ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_stickyban_matched_ip
CREATE TABLE IF NOT EXISTS `erro_stickyban_matched_ip` (
  `stickyban` varchar(32) NOT NULL,
  `matched_ip` int(10) unsigned NOT NULL,
  `first_matched` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_matched` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`stickyban`,`matched_ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: erro_watch
CREATE TABLE IF NOT EXISTS `erro_watch` (
  `ckey` varchar(32) NOT NULL,
  `reason` mediumtext NOT NULL,
  `timestamp` datetime DEFAULT NULL,
  `adminckey` varchar(32) DEFAULT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` mediumtext,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;