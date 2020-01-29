
-- clean all the data

-- uri_path
update enhanced_log_data set uri_path=REPLACE(uri_path, '+', ' ');
update enhanced_log_data set uri_path=REPLACE(uri_path, 'https://login.swissid.ch/idp/oauth2/', '');
update enhanced_log_data set uri_path='users/applications' where uri_path like 'https://login.swissid.ch:443/idp/json/users/%/oauth2/applications';
update enhanced_log_data set uri_path='users/applications' where uri_path like 'https://login.swissid.ch:443/idp/json/realms/root/realms/sesam/users/%/oauth2/applications';
update enhanced_log_data set uri_path='authorize' where uri_path like 'realms/root/realms/%/authorize';
update enhanced_log_data set uri_path='connect/jwk_uri' where uri_path like 'realms/root/realms/sesam/connect/jwk_uri';
CREATE INDEX idx_eld_uri_path ON enhanced_log_data(uri_path);

update enhanced_log_data set am_realm=REPLACE(am_realm, '/', '');

-- update enhanced_log_data set response_type=REPLACE(response_type, '%20', ' ');

-- clean oidc_scopes, i.e. remove url encoding
update enhanced_log_data set oidc_scopes=REPLACE(oidc_scopes, '+', ' ');
update enhanced_log_data set oidc_scopes=REPLACE(oidc_scopes, '%2B', ' ');
update enhanced_log_data set oidc_scopes=REPLACE(oidc_scopes, '%20', ' ');
update enhanced_log_data set oidc_scopes=REPLACE(oidc_scopes, '%3A', ':');
update enhanced_log_data set oidc_scopes=REPLACE(oidc_scopes, '%2520', ' ');
update enhanced_log_data set oidc_scopes=REPLACE(oidc_scopes, '%2C', ' ');

-- clean oidc_ui_locales
update enhanced_log_data set oidc_ui_locales=REPLACE(oidc_ui_locales, 'EN', 'en');
update enhanced_log_data set oidc_ui_locales=REPLACE(oidc_ui_locales, 'DE', 'de');
update enhanced_log_data set oidc_ui_locales=REPLACE(oidc_ui_locales, 'FR', 'fr');
update enhanced_log_data set oidc_ui_locales=REPLACE(oidc_ui_locales, 'IT', 'it');


-- add missing response_status_codes
UPDATE enhanced_log_data SET response_status_code = '200' where response_status_code is null and response_status = 'SUCCESSFUL';

-- extract oidc_client_id from ldap user column
UPDATE enhanced_log_data SET oidc_client_id = SUBSTRING_INDEX(SUBSTRING_INDEX(ldap_user,',',1),'=',-1) where ldap_user like '%,ou=agent,o=sesam,ou=services,dc=swisssign,dc=com' and oidc_client_id is null;

-- create new column client_type
ALTER TABLE enhanced_log_data ADD COLUMN client_type varchar(32) NULL AFTER oidc_client_id;
UPDATE enhanced_log_data SET client_type = 'rp' where client_type is null and oidc_client_id is not null;
UPDATE enhanced_log_data SET client_type = 'agent' where (oidc_client_id = 'account-webagent' or oidc_client_id = 'support-webagent');

UPDATE enhanced_log_data SET client_type = 'rp', uri_path='users/applications/client', oidc_client_id=SUBSTRING_INDEX(uri_path,'/',-1) where client_type is null and oidc_client_id is null and uri_path like 'https://login.swissid.ch:443/idp/json/users/%/oauth2/applications/%';

-- create new column 'ido_id' and extract ido_id from the user column
ALTER TABLE enhanced_log_data ADD COLUMN ido_id varchar(256) NULL AFTER oidc_ui_locales;
ALTER TABLE enhanced_log_data ADD COLUMN ido_type varchar(32) NULL AFTER ido_id;
UPDATE enhanced_log_data SET ido_id = SUBSTRING_INDEX(SUBSTRING_INDEX(ldap_user,',',1),'=',-1), ido_type = 'enduser' where ldap_user like '%,ou=user,o=sesam,ou=services,dc=swisssign,dc=com' and ido_id is null;
UPDATE enhanced_log_data SET ido_id = SUBSTRING_INDEX(SUBSTRING_INDEX(ldap_user,',',1),'=',-1), ido_type = 'admin' where ldap_user like '%,ou=user,o=support,ou=services,dc=swisssign,dc=com' and ido_id is null;
CREATE INDEX idx_eld_ido_id ON enhanced_log_data(ido_id);

-- fill email address for type monitoring
ALTER TABLE enhanced_log_data ADD COLUMN ido_email varchar(256) NULL AFTER ido_type;
UPDATE enhanced_log_data SET ido_id = 'd9d4d5e5-4846-47ad-a0e3-9eb6c09c7c45', ido_type = 'monitoring', ido_email = 'operations.swissid+e2e@swisssign.com' where ldap_user = 'd9d4d5e5-4846-47ad-a0e3-9eb6c09c7c45' and ido_id is null;
UPDATE enhanced_log_data SET ido_id = 'd5de9fc6-2f59-4b85-bd2e-25a86d8c426c', ido_type = 'monitoring', ido_email = 'betriebit265@post.ch' where ldap_user = 'd5de9fc6-2f59-4b85-bd2e-25a86d8c426c' and ido_id is null;
UPDATE enhanced_log_data SET ido_id = '48fa1b97-d3b6-42e0-b425-8c8b6e18f8f5', ido_type = 'monitoring', ido_email = 'e2e@post.ch' where ldap_user = '48fa1b97-d3b6-42e0-b425-8c8b6e18f8f5' and ido_id is null;
UPDATE enhanced_log_data SET ido_id = 'e7ef8a16-636b-43a2-b53c-d73c97aa03e7', ido_type = 'monitoring', ido_email = 'marco.mojana+e2e@post.ch' where ldap_user = 'e7ef8a16-636b-43a2-b53c-d73c97aa03e7' and ido_id is null;
UPDATE enhanced_log_data SET ido_id = '44327a8d-011d-484b-a90b-68c483ebf84b', ido_type = 'monitoring', ido_email = 'ringier.connect.e2e@gmail.com' where ldap_user = 'd44327a8d-011d-484b-a90b-68c483ebf84b' and ido_id is null;
CREATE INDEX idx_eld_ido_type ON enhanced_log_data(ido_type);

-- important: order is relevant!
-- set some additional ido_id's
UPDATE enhanced_log_data SET ido_id = ldap_user, ido_type = 'enduser' where ido_id is null and ldap_user in (
select * From (
SELECT distinct log.ldap_user FROM enhanced_log_data log
join orig_identity_owner ido on log.ldap_user = ido.user_id
where (log.ldap_user not like '%,ou=user,o=sesam,ou=services,dc=swisssign,dc=com' 
and log.ldap_user not like '%,ou=agent,o=sesam,ou=services,dc=swisssign,dc=com' 
and log.ldap_user not like '%,ou=user,o=support,ou=services,dc=swisssign,dc=com') and log.ldap_user not like '%=') t);

-- fill email address for type enduser
UPDATE enhanced_log_data log
JOIN orig_identity_owner ido on log.ido_id = ido.user_id
SET log.ido_email = ido.email
WHERE log.ido_id is not null AND log.ido_type = 'enduser' AND log.ido_email is null;

CREATE INDEX idx_eld_oidc_client_id ON enhanced_log_data(oidc_client_id);
CREATE INDEX idx_eld_client_type ON enhanced_log_data(client_type);
CREATE INDEX idx_eld_http_method ON enhanced_log_data(http_method);
CREATE INDEX idx_eld_date_day ON enhanced_log_data(date_day);
CREATE INDEX idx_eld_date_month ON enhanced_log_data(date_month);
CREATE INDEX idx_eld_date_hour ON enhanced_log_data(date_hour);
CREATE INDEX idx_eld_loc_country ON enhanced_log_data(loc_country);
CREATE INDEX idx_eld_loc_country_code ON enhanced_log_data(loc_country_code);
CREATE INDEX idx_eld_am_realm ON enhanced_log_data(am_realm);
CREATE INDEX idx_eld_src_software_type ON enhanced_log_data(src_software_type);

ALTER TABLE enhanced_log_data ADD COLUMN date_month_nr int NULL AFTER date_month;
UPDATE enhanced_log_data SET date_month_nr = 3 where date_month = 'march';
UPDATE enhanced_log_data SET date_month_nr = 4 where date_month = 'april';
UPDATE enhanced_log_data SET date_month_nr = 5 where date_month = 'may';
UPDATE enhanced_log_data SET date_month_nr = 6 where date_month = 'june';
UPDATE enhanced_log_data SET date_month_nr = 7 where date_month = 'july';
UPDATE enhanced_log_data SET date_month_nr = 8 where date_month = 'august';
UPDATE enhanced_log_data SET date_month_nr = 9 where date_month = 'september';
UPDATE enhanced_log_data SET date_month_nr = 10 where date_month = 'october';
UPDATE enhanced_log_data SET date_month_nr = 11 where date_month = 'november';
UPDATE enhanced_log_data SET date_month_nr = 12 where date_month = 'december';
CREATE INDEX idx_eld_date_month_nr ON enhanced_log_data(date_month_nr);

CREATE INDEX idx_eld_path_realm ON enhanced_log_data(uri_path,am_realm);

ALTER TABLE enhanced_log_data ADD COLUMN label_nr int NOT NULL AFTER time_stamp;
UPDATE enhanced_log_data SET label_nr = 0;
