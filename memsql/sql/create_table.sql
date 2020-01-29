create database swissid;

CREATE TABLE IF NOT EXISTS `idp_audit_events` (
    `uuid` varchar(128) NOT NULL,
    `time_stamp` varchar(128) NULL,
    `event_id` varchar(128) NULL,
    `ido_id` varchar(128) NULL,
    PRIMARY KEY(uuid),
    INDEX idx_iae_event_id (event_id),
    INDEX idx_iae_ido_id (ido_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=UTF8_bin;