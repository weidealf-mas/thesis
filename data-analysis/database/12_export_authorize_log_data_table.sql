-- export enhanced_log_data_authorize to swissid_authorize_logs_april_to_sept_2019.csv
SELECT
	time_stamp,
	label_nr,
	label,
	-- date_day,
	-- date_day_name,
	date_weekday,
	-- date_month,
	-- date_month_nr,
	-- date_year,
	date_hour,
	-- date_minute,
	-- date_second,
	-- transaction_id,
	-- tracking_ids,
	src_ip,
	src_software_name, 
	src_operating_system_name, 
	src_software_type, 
	src_software_sub_type, 
	src_hardware_type, 
	src_hardware_sub_type,
	-- dest_ip,
	-- uri_path,
	http_method,
	-- request_operation,
	-- request_protocol,
	-- http_referrer,
	response_status,
	response_status_code,
	-- response_detail_reason,
	response_time_ms,
	response_time_cat,
	oidc_response_type,
	oidc_acr_values,
	-- oidc_login_hint,
	oidc_client_id,
	client_name,
	client_type,
	ido_id,
	ido_email,
	ido_type,
	oidc_scopes,
	oidc_ui_locales,
	-- am_realm,
	-- am_component,
	loc_country,
	loc_region,
	loc_city,
	loc_country_code
	-- loc_latitude,
	-- loc_longitude,
	-- loc_zip_code,
	-- loc_time_zone,
	-- ldap_user,
	-- user_agent,
	-- http_query_parameters
INTO OUTFILE '/tmp/swissid_authorize_logs_april_to_sept_2019.csv'
FIELDS TERMINATED BY '\t' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM enhanced_log_data_authorize
where date_month_nr > 3
order by time_stamp;
