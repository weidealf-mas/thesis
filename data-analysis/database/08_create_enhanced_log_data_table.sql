
-- runs about 440 seconds
-- create the final working table with all the existing data
CREATE TABLE enhanced_log_data AS
	SELECT
    	log.timestamp as time_stamp,
		log.date_mday as date_day,
		log.date_month,
		log.date_year,
		log.date_hour,
		log.date_minute,
		log.date_second,
		log.transaction_id,
		log.tracking_ids,
		log.x_forwarded_for as src_ip,
        ua.software_name as src_software_name, 
        ua.operating_system_name as src_operating_system_name, 
        ua.software_type as src_software_type, 
        ua.software_sub_type as src_software_sub_type, 
        ua.hardware_type as src_hardware_type, 
        ua.hardware_sub_type as src_hardware_sub_type,
		log.dest_ip,
		log.uri_path,
		log.http_method,
		log.request_operation,
		log.request_protocol,
		log.http_referrer,
		log.response_status,
		log.response_status_code,
		log.response_detail_reason,
		log.response_time_ms,
		log.response_type as oidc_response_type,
		log.acr_values as oidc_acr_values,
		log.login_hint as oidc_login_hint,
		log.client_id as oidc_client_id,
		log.scopes as oidc_scopes,
		log.ui_locales as oidc_ui_locales,
        rp.client_name as client_name,
		log.realm as am_realm,
		log.component as am_component,
        loc.country_name as loc_country,
        loc.region_name as loc_region,
        loc.city_name as loc_city,
        loc.country_code as loc_country_code,
        loc.latitude as loc_latitude,
        loc.longitude as loc_longitude,
        loc.zip_code as loc_zip_code,
        loc.time_zone as loc_time_zone,
		log.user as ldap_user,
		log.user_agent,
        log.http_query_parameters
		FROM orig_log_data log
    left join swissid_logs.whatismybrowser_useragent ua on log.user_agent = ua.user_agent
    left join orig_relying_party rp on log.client_id = rp.client_id
    left join tmp_log_data_ip_location loc on log.x_forwarded_for = loc.src_ip
    order by log.timestamp;
    
    
CREATE INDEX idx_eld_time_stamp ON enhanced_log_data(time_stamp);
