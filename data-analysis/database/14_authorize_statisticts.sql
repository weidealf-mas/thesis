SELECT * FROM enhanced_log_data_authorize
where oidc_login_hint is not null;

SELECT count(*) FROM enhanced_log_data_authorize;
-- 23'156'412 / 12'418'400

SELECT date_day, count(date_day) as anzahl FROM enhanced_log_data_authorize
group by date_day order by date_day asc;

SELECT date_month, count(date_month) as anzahl FROM enhanced_log_data_authorize
group by date_month order by anzahl asc;

SELECT src_ip, count(src_ip) as anzahl FROM enhanced_log_data_authorize
group by src_ip order by anzahl desc;

SELECT src_software_name, count(src_software_name) as anzahl FROM enhanced_log_data_authorize
group by src_software_name order by anzahl desc;

SELECT src_operating_system_name, count(src_operating_system_name) as anzahl FROM enhanced_log_data_authorize
group by src_operating_system_name order by anzahl desc;

SELECT src_software_type, count(src_software_type) as anzahl FROM enhanced_log_data_authorize
group by src_software_type order by anzahl desc;

SELECT src_software_sub_type, count(src_software_sub_type) as anzahl FROM enhanced_log_data_authorize
group by src_software_sub_type order by anzahl desc;

SELECT src_hardware_type, count(src_hardware_type) as anzahl FROM enhanced_log_data_authorize
group by src_hardware_type order by anzahl desc;

SELECT src_hardware_sub_type, count(src_hardware_sub_type) as anzahl FROM enhanced_log_data_authorize
group by src_hardware_sub_type order by anzahl desc;

SELECT uri_path, count(uri_path) as anzahl FROM enhanced_log_data
group by uri_path order by anzahl desc;

SELECT http_method, count(http_method) as anzahl FROM enhanced_log_data_authorize
group by http_method order by anzahl desc;

SELECT response_status_code, count(response_status_code) as anzahl FROM enhanced_log_data_authorize
group by response_status_code order by anzahl desc;

SELECT response_status, count(response_status) as anzahl FROM enhanced_log_data_authorize
group by response_status order by anzahl desc;

SELECT response_time_ms, count(response_time_ms) as anzahl FROM enhanced_log_data_authorize
group by response_time_ms order by response_time_ms desc;

SELECT oidc_response_type, count(oidc_response_type) as anzahl FROM enhanced_log_data_authorize
group by oidc_response_type order by anzahl desc;

SELECT oidc_acr_values, count(oidc_acr_values) as anzahl FROM enhanced_log_data_authorize
group by oidc_acr_values order by anzahl desc;

SELECT oidc_login_hint, count(oidc_login_hint) as anzahl FROM enhanced_log_data_authorize
group by oidc_login_hint order by anzahl desc;

SELECT oidc_client_id, count(oidc_client_id) as anzahl FROM enhanced_log_data_authorize
group by oidc_client_id order by anzahl desc;

SELECT oidc_scopes, count(oidc_scopes) as anzahl FROM enhanced_log_data_authorize
group by oidc_scopes order by anzahl desc;

SELECT oidc_ui_locales, count(oidc_ui_locales) as anzahl FROM enhanced_log_data_authorize
group by oidc_ui_locales order by anzahl desc;

SELECT client_type, count(client_type) as anzahl FROM enhanced_log_data_authorize
group by client_type order by anzahl desc;

SELECT client_name, count(client_name) as anzahl FROM enhanced_log_data_authorize
group by client_name order by anzahl desc;

SELECT ido_type, count(ido_type) as anzahl FROM enhanced_log_data_authorize
group by ido_type order by anzahl desc;

SELECT am_realm, count(am_realm) as anzahl FROM enhanced_log_data
group by am_realm order by anzahl desc;

SELECT loc_country, count(loc_country) as anzahl FROM enhanced_log_data_authorize
group by loc_country order by anzahl desc;

SELECT response_detail_reason, count(response_detail_reason) as anzahl FROM enhanced_log_data_authorize
group by response_detail_reason order by anzahl desc;

SELECT request_operation, count(request_operation) as anzahl FROM enhanced_log_data_authorize
group by request_operation order by anzahl desc;

SELECT request_protocol, count(request_protocol) as anzahl FROM enhanced_log_data_authorize
group by request_protocol order by anzahl desc;

SELECT am_component, count(am_component) as anzahl FROM enhanced_log_data
group by am_component order by anzahl desc;

SELECT label_nr, count(label_nr) as anzahl FROM enhanced_log_data_authorize
group by label_nr order by anzahl desc;

SELECT label, count(label) as anzahl FROM enhanced_log_data_authorize
group by label order by anzahl desc;

-- select all valid ido's with more than 500 records
SELECT ido_type, ido_id, ido_email, count(ido_id) as anzahl FROM enhanced_log_data_authorize
where label = 0 and ido_type = 'enduser'
group by ido_type, ido_id, ido_email 
having anzahl > 500
order by anzahl desc;

SELECT http_referrer, count(http_referrer) as anzahl FROM enhanced_log_data_authorize
group by http_referrer order by anzahl desc;

-- access count per day
SELECT date_month_nr, date_day, count(date_day) as anzahl FROM enhanced_log_data_authorize
where date_month_nr > 3
group by date_month_nr, date_day order by date_month_nr, date_day asc;

-- access count per weekday
SELECT date_weekday, count(date_weekday) as anzahl FROM enhanced_log_data_authorize
where date_month_nr > 3
group by date_weekday order by date_weekday asc;

SELECT date_month_nr, date_weekday, count(date_weekday) as anzahl FROM enhanced_log_data_authorize
where date_month_nr > 3
group by date_month_nr, date_weekday order by date_month_nr, date_weekday asc;

-- bot access
SELECT date_month_nr, date_weekday, count(date_weekday) as anzahl FROM enhanced_log_data_authorize
where date_month_nr > 3 and src_software_type = 'bot'
group by date_month_nr, date_weekday order by date_month_nr, date_weekday asc;

-- anomaly
SELECT date_month_nr, date_day, count(date_day) as anzahl FROM enhanced_log_data_authorize
where date_month_nr > 3 and label = 1
group by date_month_nr, date_day order by date_month_nr, date_day asc;

-- suspect
SELECT date_month_nr, date_day, count(date_day) as anzahl FROM enhanced_log_data_authorize
where date_month_nr > 3 and label = 2
group by date_month_nr, date_day order by date_month_nr, date_day asc;

-- normal
SELECT date_month_nr, date_day, count(date_day) as anzahl FROM enhanced_log_data_authorize
where date_month_nr > 3 and label = 0
group by date_month_nr, date_day order by date_month_nr, date_day asc;
