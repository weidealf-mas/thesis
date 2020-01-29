
-- create the final working table for the authorize endpoint
CREATE TABLE enhanced_log_data_authorize AS
	SELECT * FROM enhanced_log_data where uri_path = 'authorize' and am_realm = 'sesam'
    order by time_stamp;
    
CREATE INDEX idx_elda_time_stamp ON enhanced_log_data_authorize(time_stamp);
CREATE INDEX idx_elda_ido_id ON enhanced_log_data_authorize(ido_id);
CREATE INDEX idx_elda_ido_type ON enhanced_log_data_authorize(ido_type);
CREATE INDEX idx_elda_oidc_client_id ON enhanced_log_data_authorize(oidc_client_id);
CREATE INDEX idx_elda_client_type ON enhanced_log_data_authorize(client_type);
CREATE INDEX idx_elda_http_method ON enhanced_log_data_authorize(http_method);
CREATE INDEX idx_elda_date_day ON enhanced_log_data_authorize(date_day);
CREATE INDEX idx_elda_date_month ON enhanced_log_data_authorize(date_month);
CREATE INDEX idx_elda_date_hour ON enhanced_log_data_authorize(date_hour);
CREATE INDEX idx_elda_loc_country ON enhanced_log_data_authorize(loc_country);
CREATE INDEX idx_elda_loc_country_code ON enhanced_log_data_authorize(loc_country_code);
CREATE INDEX idx_elda_src_software_type ON enhanced_log_data_authorize(src_software_type);
CREATE INDEX idx_elda_date_month_nr ON enhanced_log_data_authorize(date_month_nr);
CREATE INDEX idx_elda_client_name ON enhanced_log_data_authorize(client_name);
CREATE INDEX idx_elda_oidc_response_type ON enhanced_log_data_authorize(oidc_response_type);
CREATE INDEX idx_elda_ldap_user ON enhanced_log_data_authorize(ldap_user);
CREATE INDEX idx_elda_oidc_scopes ON enhanced_log_data_authorize(oidc_scopes);
CREATE INDEX idx_elda_label_nr ON enhanced_log_data_authorize(label_nr);
CREATE INDEX idx_elda_response_status ON enhanced_log_data_authorize(response_status);
