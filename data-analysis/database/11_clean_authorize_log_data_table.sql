
-- clean and extend the data
UPDATE enhanced_log_data_authorize SET src_operating_system_name = 'macOS' where src_operating_system_name = 'Mac OS X';

UPDATE enhanced_log_data_authorize set oidc_response_type=REPLACE(oidc_response_type, '%20', ' ');
UPDATE enhanced_log_data_authorize set ido_id=ldap_user where ido_id is null and (ldap_user='tomas.felner' or ldap_user='gianluca.germana');
UPDATE enhanced_log_data_authorize set ido_id=ldap_user where ido_id is null and ldap_user like '%-%-%-%-%';

UPDATE enhanced_log_data_authorize set ido_type='admin', ido_email='tomas.felner@swisssign.com' where ido_id='tomas.felner';
UPDATE enhanced_log_data_authorize set ido_type='admin', ido_email='gaetano.debenedetto@swisssign.com' where ido_id='gaetano.debenedetto';
UPDATE enhanced_log_data_authorize set ido_type='admin', ido_email='gianluca.germana@post.ch' where ido_id='gianluca.germana';
UPDATE enhanced_log_data_authorize set ido_type='admin', ido_email='felix.maurer@post.ch' where ido_id='felix.maurer';

UPDATE enhanced_log_data_authorize set ido_type='monitoring' where ido_email='betriebit265@post.ch';

UPDATE enhanced_log_data_authorize set ido_type='enduser' where ido_id in (
select * From (
SELECT distinct ido_id FROM enhanced_log_data_authorize 
where ido_id is not null and ido_type is null) t
) and ido_type is null;

-- drop columns having just one value!
ALTER TABLE enhanced_log_data_authorize DROP COLUMN am_component;
ALTER TABLE enhanced_log_data_authorize DROP COLUMN am_realm;
ALTER TABLE enhanced_log_data_authorize DROP COLUMN uri_path;


ALTER TABLE enhanced_log_data_authorize ADD COLUMN date_day_name varchar(32) NULL AFTER date_day;
ALTER TABLE enhanced_log_data_authorize ADD COLUMN date_weekday int NULL AFTER date_day_name;
UPDATE enhanced_log_data_authorize set date_day_name=DAYNAME(time_stamp);
UPDATE enhanced_log_data_authorize set date_weekday=WEEKDAY(time_stamp);
CREATE INDEX idx_elda_date_day_name ON enhanced_log_data_authorize(date_day_name);
CREATE INDEX idx_elda_date_weekday ON enhanced_log_data_authorize(date_weekday);


-- replace NULL values with '-'
UPDATE enhanced_log_data_authorize set date_month='-' where date_month is null;
UPDATE enhanced_log_data_authorize set transaction_id='-' where transaction_id is null;
UPDATE enhanced_log_data_authorize set tracking_ids='-' where tracking_ids is null;
UPDATE enhanced_log_data_authorize set src_ip='-' where src_ip is null;
UPDATE enhanced_log_data_authorize set src_software_name='-' where src_software_name is null;
UPDATE enhanced_log_data_authorize set src_operating_system_name='-' where src_operating_system_name is null;
UPDATE enhanced_log_data_authorize set src_software_type='-' where src_software_type is null;
UPDATE enhanced_log_data_authorize set src_software_sub_type='-' where src_software_sub_type is null;
UPDATE enhanced_log_data_authorize set src_hardware_type='-' where src_hardware_type is null;
UPDATE enhanced_log_data_authorize set src_hardware_sub_type='-' where src_hardware_sub_type is null;
UPDATE enhanced_log_data_authorize set http_method='-' where http_method is null;
UPDATE enhanced_log_data_authorize set request_operation='-' where request_operation is null;
UPDATE enhanced_log_data_authorize set request_protocol='-' where request_protocol is null;
UPDATE enhanced_log_data_authorize set http_referrer='-' where http_referrer is null;
UPDATE enhanced_log_data_authorize set response_status='-' where response_status is null;
UPDATE enhanced_log_data_authorize set response_status_code='-' where response_status_code is null;
UPDATE enhanced_log_data_authorize set response_detail_reason='-' where response_detail_reason is null;
UPDATE enhanced_log_data_authorize set response_time_ms=0 where response_time_ms is null;
UPDATE enhanced_log_data_authorize set oidc_response_type='-' where oidc_response_type is null;
UPDATE enhanced_log_data_authorize set oidc_acr_values='-' where oidc_acr_values is null;
UPDATE enhanced_log_data_authorize set oidc_login_hint='-' where oidc_login_hint is null;
UPDATE enhanced_log_data_authorize set oidc_client_id='-' where oidc_client_id is null;
UPDATE enhanced_log_data_authorize set oidc_scopes='-' where oidc_scopes is null;
UPDATE enhanced_log_data_authorize set oidc_ui_locales='-' where oidc_ui_locales is null;
UPDATE enhanced_log_data_authorize set client_name='-' where client_name is null;
UPDATE enhanced_log_data_authorize set ldap_user='-' where ldap_user is null;
UPDATE enhanced_log_data_authorize set user_agent='-' where user_agent is null;
UPDATE enhanced_log_data_authorize set http_query_parameters='-' where http_query_parameters is null;
UPDATE enhanced_log_data_authorize set ido_id='-' where ido_id is null;
UPDATE enhanced_log_data_authorize set ido_type='-' where ido_type is null;
UPDATE enhanced_log_data_authorize set ido_email='-' where ido_email is null;
UPDATE enhanced_log_data_authorize set client_type='-' where client_type is null;

-- clean the data
UPDATE enhanced_log_data_authorize set http_referrer=REPLACE(http_referrer, '%3d', '%3D');
UPDATE enhanced_log_data_authorize set http_referrer=REPLACE(http_referrer, '%3a', '%3A');
UPDATE enhanced_log_data_authorize set http_referrer=REPLACE(http_referrer, '%2f', '%2F');

-- UPDATE enhanced_log_data_authorize set http_referrer=URLDECODER(http_referrer) where label_nr = 0 and http_referrer != '-';
-- UPDATE enhanced_log_data_authorize set http_referrer=URLDECODER(http_referrer) where label_nr = 2 and http_referrer != '-';

-- group the values together to reduce column values
UPDATE enhanced_log_data_authorize set src_software_name=REPLACE(src_software_name, ' ', '_');

UPDATE enhanced_log_data_authorize set src_operating_system_name='macOS' where src_operating_system_name='Mac OS X';
UPDATE enhanced_log_data_authorize set src_operating_system_name='other' where src_operating_system_name in ('Fire OS','FreeBSD','Windows Mobile','OpenBSD','RIM Tablet OS','A UNIX based OS');
UPDATE enhanced_log_data_authorize set src_operating_system_name=REPLACE(src_operating_system_name, ' ', '_');

UPDATE enhanced_log_data_authorize set oidc_response_type=REPLACE(oidc_response_type, ' ', '_');

UPDATE enhanced_log_data_authorize set oidc_acr_values='loa_1' where oidc_acr_values in ('loa-1','loa-1.1','loa-1.2','qoa1.4','qoa1','qoa1.1');
UPDATE enhanced_log_data_authorize set oidc_acr_values='loa_2' where oidc_acr_values != 'loa_1' and oidc_acr_values in ('loa-2','loa-2.1','loa-2.3','loa-2.2','qoa2.4','qoa2','qoa2.2');

UPDATE enhanced_log_data_authorize set oidc_scopes='openid_profile_email' where oidc_scopes in ('openid email profile','openid profile email','openid profile  email','email profile openid');
UPDATE enhanced_log_data_authorize set oidc_scopes='openid_profile_email_phone' where oidc_scopes in ('openid profile email phone','openid email phone profile','phone openid profile email','openid email profile phone');

UPDATE enhanced_log_data_authorize set oidc_scopes=REPLACE(oidc_scopes, ' ', '_');

UPDATE enhanced_log_data_authorize set oidc_scopes='read:profile_openid_email' where oidc_scopes= 'read:profile_openid_email_';


-- SELECT * FROM enhanced_log_data_authorize where oidc_response_type = 'code%28%28%27.%2C.' or oidc_response_type like 'code%26client_id=klp-client%';
-- SELECT * FROM enhanced_log_data_authorize where oidc_client_id = 'insign' and loc_country_code != 'CH';

-- SELECT count(*) FROM enhanced_log_data_authorize where ldap_user is null;  -- 7'435'205
-- SELECT count(*) FROM enhanced_log_data_authorize where ido_id='-';  -- 7'435'488 => 4'982'912
-- SELECT count(*) FROM enhanced_log_data_authorize where ido_id is null and ldap_user is not null; -- 283
-- SELECT count(*) FROM enhanced_log_data_authorize where ido_id !='-' and oidc_client_id='-'; -- 4'982'912 - 4'982'899 = 13

-- classify the data into normal, anomaly and suspect
UPDATE enhanced_log_data_authorize SET label_nr = 2, oidc_response_type='code' where oidc_response_type like 'code%2%';
UPDATE enhanced_log_data_authorize SET label_nr = 2, oidc_acr_values='loa_1' where oidc_acr_values = 'loa-1%28%28%27.%2C.' or oidc_acr_values = 'loa-1.1/themes/sesam/images/favicon/apple-touch-icon.png';
UPDATE enhanced_log_data_authorize SET label_nr = 2, oidc_acr_values='loa_2' where oidc_acr_values = 'qoa2","qoa2';
UPDATE enhanced_log_data_authorize SET label_nr = 2, oidc_scopes='openid_profile_email' where oidc_scopes = 'openid email profile%28%28%27. .' and label_nr != 1;
UPDATE enhanced_log_data_authorize SET label_nr = 2, oidc_scopes='offline_access' where oidc_scopes = 'EPOF_ADDR_VALID offline_access' and label_nr != 1;
UPDATE enhanced_log_data_authorize SET label_nr = 1 where src_software_type = 'bot';
UPDATE enhanced_log_data_authorize SET label_nr = 1 where oidc_scopes in ('-', 'read:profile', 'offline_access');
UPDATE enhanced_log_data_authorize SET label_nr = 1 where oidc_client_id !='-' and client_name = '-';
UPDATE enhanced_log_data_authorize SET label_nr = 2 where ido_id = '-' and ldap_user != '-' and label_nr != 1;
UPDATE enhanced_log_data_authorize SET label_nr = 1 where ido_id = '-' and oidc_client_id = '-';
UPDATE enhanced_log_data_authorize SET label_nr = 2 where src_software_type = 'application' and label_nr != 1;
UPDATE enhanced_log_data_authorize SET label_nr = 2 where ido_id='-' and label_nr != 1;
UPDATE enhanced_log_data_authorize SET label_nr = 1 where http_method = 'HEAD' or http_method = 'OPTIONS';
UPDATE enhanced_log_data_authorize SET label_nr = 1 where response_status = 'FAILED' and ido_id = '-';
UPDATE enhanced_log_data_authorize SET label_nr = 1 where response_status = 'FAILED' and ido_id != '-';

-- add a label column
ALTER TABLE enhanced_log_data_authorize ADD COLUMN label varchar(16) NULL AFTER label_nr;
UPDATE enhanced_log_data_authorize SET label = 'normal' where label_nr = 0;
UPDATE enhanced_log_data_authorize SET label = 'anomaly' where label_nr = 1;
UPDATE enhanced_log_data_authorize SET label = 'suspect' where label_nr = 2;

CREATE INDEX idx_elda_label ON enhanced_log_data_authorize(label);

-- categorize the response into different classes
ALTER TABLE enhanced_log_data_authorize ADD COLUMN response_time_cat varchar(16) NULL AFTER response_time_ms;

UPDATE enhanced_log_data_authorize SET response_time_cat = CASE
    when response_time_ms < 10 then 'under_10'
	when response_time_ms >= 10 and response_time_ms <= 50 then 'under_50'
	when response_time_ms >= 50 and response_time_ms <= 100 then 'under_100'
	when response_time_ms >= 100 and response_time_ms <= 1000 then 'under_1000'
	when response_time_ms >= 1000 and response_time_ms <= 5000 then 'under_5000'
	when response_time_ms >= 5000 and response_time_ms <= 10000 then 'under_10000'
	else 'over_10000'
	end;

CREATE INDEX idx_elda_response_time_cat ON enhanced_log_data_authorize(response_time_cat);

ANALYZE TABLE enhanced_log_data_authorize;
OPTIMIZE TABLE enhanced_log_data_authorize;
