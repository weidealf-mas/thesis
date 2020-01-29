
-- duration about 120 sec
-- truncate table orig_log_data;

LOAD DATA INFILE '/tmp/data.csv' INTO TABLE orig_log_data
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
IGNORE 1 LINES
(@vtimestamp,date_mday,date_month,date_year,date_hour,date_minute,date_second,transaction_id,@vtracking_ids,x_forwarded_for,@vdest_ip,@vrealm,@vuser_agent,@vuri_path,@vacr_values,@vlogin_hint,@vclient_id,@vcomponent,@vhttp_method,@vrequest_operation,@vrequest_protocol,@vhttp_referrer,@vresponse_status,@vresponse_status_code,@vresponse_detail_reason,@vresponse_time_ms,@vresponse_type,@vscopes,@vui_locales,@vuser,@vhttp_query_parameters)
SET
timestamp = str_to_date(@vtimestamp,'%Y-%m-%dT%T.%fZ'),
tracking_ids = nullif(@vtracking_ids,''),
dest_ip = nullif(@vdest_ip,''),
realm = nullif(@vrealm,''),
user_agent = nullif(@vuser_agent,''),
uri_path = nullif(@vuri_path,''),
acr_values = nullif(@vacr_values,''),
login_hint = nullif(@vlogin_hint,''),
client_id = nullif(@vclient_id,''),
component = nullif(@vcomponent,''),
http_method = nullif(@vhttp_method,''),
request_operation = nullif(@vrequest_operation,''),
request_protocol = nullif(@vrequest_protocol,''),
http_referrer = nullif(@vhttp_referrer,''),
response_status = nullif(@vresponse_status,''),
response_status_code = nullif(@vresponse_status_code,''),
response_detail_reason = nullif(@vresponse_detail_reason,''),
response_time_ms = nullif(@vresponse_time_ms,''),
response_type = nullif(@vresponse_type,''),
scopes = nullif(@vscopes,''),
ui_locales = nullif(@vui_locales,''),
user = nullif(@vuser,''),
http_query_parameters = nullif(@vhttp_query_parameters,'');
