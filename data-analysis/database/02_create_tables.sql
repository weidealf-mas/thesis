
-- create main log data table
DROP TABLE IF EXISTS `orig_log_data`;

CREATE TABLE IF NOT EXISTS `orig_log_data` (
	`timestamp` datetime(3) NOT NULL,
	`date_mday` int unsigned NOT NULL,
	`date_month` varchar(32) NOT NULL,
	`date_year` int unsigned NOT NULL,
	`date_hour` int unsigned NOT NULL,
	`date_minute` int unsigned NOT NULL,
	`date_second` int unsigned NOT NULL,
	`transaction_id` varchar(256) NOT NULL,
    `tracking_ids` varchar(256) NULL,
	`x_forwarded_for` varchar(128) NOT NULL,
	`dest_ip` varchar(16) NULL,
	`realm` varchar(128) NULL,
	`user_agent` varchar(2048) NULL,
	`uri_path` varchar(128) NULL,
	`acr_values` varchar(128) NULL,
	`login_hint` varchar(128) NULL,
	`client_id` varchar(128) NULL,
	`component` varchar(128) NULL,
	`http_method` varchar(128) NULL,
	`request_operation`	varchar(128) NULL,
	`request_protocol` varchar(128) NULL,
    `http_referrer` varchar(3072) NULL,
	`response_status` varchar(128) NULL,
    `response_status_code` varchar(128) NULL,
    `response_detail_reason` varchar(128) NULL,
	`response_time_ms` int unsigned NULL,
	`response_type` varchar(512) NULL,
	`scopes` varchar(2048) NULL,
	`ui_locales` varchar(32) NULL,
	`user` varchar(128) NULL,
    `http_query_parameters` varchar(4000) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


-- create relying party table
DROP TABLE IF EXISTS `orig_relying_party`;

CREATE TABLE IF NOT EXISTS `orig_relying_party` (

	`client_id` varchar(128) NULL,
	`client_name` varchar(256) NULL,
     PRIMARY KEY (client_id)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


 -- create identity owner table
DROP TABLE IF EXISTS `orig_identity_owner`;

CREATE TABLE IF NOT EXISTS `orig_identity_owner` (

	`ldap_id` varchar(254) NOT NULL,
    `email` varchar(128) NULL,
	`firstname` varchar(64) NULL,
    `gender` varchar(64) NULL,
    `lastname` varchar(64) NOT NULL,
    `name` varchar(128) NOT NULL,
	`consent` varchar(256) NULL,
    `phone_number` varchar(128) NOT NULL,
    
    UNIQUE KEY (ldap_id)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
