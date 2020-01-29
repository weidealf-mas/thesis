-- OPTIMIZE TABLE swissid_logs.orig_log_data;

-- create necessary join indexes
CREATE INDEX idx_old_timestamp ON orig_log_data(timestamp);
CREATE INDEX idx_old_user_agent ON orig_log_data(user_agent);
CREATE INDEX idx_old_client_id ON orig_log_data(client_id);
CREATE INDEX idx_old_x_forwarded_for ON orig_log_data(x_forwarded_for);

-- create ip_number table based on orig_log_data ip addresses
CREATE TABLE tmp_log_data_ip_number AS
select src_ip, ip_to_calc, (a + b + c + d) as ip_number FROM (
  SELECT 
    src_ip,
    ip_to_calc,
    16777216 * CAST(SUBSTRING_INDEX(ip_to_calc,'.',1) AS INT) as a, 
    65536 * CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip_to_calc,'.',2),'.',-1) AS INT) as b, 
    256 * CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip_to_calc,'.',-2),'.',1) AS INT) as c, 
    CAST(SUBSTRING_INDEX(ip_to_calc,'.',-1) AS INT) as d
   FROM ( SELECT distinct x_forwarded_for as src_ip, SUBSTRING_INDEX(x_forwarded_for,',',-1) as ip_to_calc FROM orig_log_data order by x_forwarded_for ) tmp_1
) tmp_2;

-- create necessary join indexes
CREATE INDEX idx_tldin_src_ip ON tmp_log_data_ip_number(src_ip);
CREATE INDEX idx_tldin_ip_number ON tmp_log_data_ip_number(ip_number);


-- create the ip location mapping table
CREATE TABLE tmp_log_data_ip_location AS
SELECT * FROM tmp_log_data_ip_number ip, swissid_logs.ip2location_db11 loc
where loc.ip_from <= ip.ip_number and ip.ip_number <= loc.ip_to;

-- create necessary join indexes
CREATE INDEX idx_tldil_src_ip ON tmp_log_data_ip_location(src_ip);
CREATE INDEX idx_tldil_country_name ON tmp_log_data_ip_location(country_name);
