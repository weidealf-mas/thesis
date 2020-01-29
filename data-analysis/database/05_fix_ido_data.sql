update swissid_logs_prod.orig_identity_owner set ldap_id=REPLACE(ldap_id, 'dn: ', '');
update swissid_logs_prod.orig_identity_owner set email=REPLACE(email, 'mail: ', '');
update swissid_logs_prod.orig_identity_owner set firstname=REPLACE(firstname, 'givenName: ', '');
update swissid_logs_prod.orig_identity_owner set gender=REPLACE(gender, 'sesamGender: 2', 'female');
update swissid_logs_prod.orig_identity_owner set gender=REPLACE(gender, 'sesamGender: 1', 'male');
update swissid_logs_prod.orig_identity_owner set lastname=REPLACE(lastname, 'sn: ', '');
update swissid_logs_prod.orig_identity_owner set name=REPLACE(name, 'cn: ', '');
update swissid_logs_prod.orig_identity_owner set consent=REPLACE(consent, 'oauth2SaveConsent: ', '');
update swissid_logs_prod.orig_identity_owner set phone_number=REPLACE(phone_number, 'telephoneNumber: ', '');

-- add column user_id based on ldap_id value
ALTER TABLE swissid_logs_prod.orig_identity_owner ADD COLUMN user_id varchar(128) NOT NULL AFTER ldap_id;
update swissid_logs_prod.orig_identity_owner set user_id=REPLACE(ldap_id, ',ou=people,dc=swisssign,dc=com', '');
update swissid_logs_prod.orig_identity_owner set user_id=REPLACE(user_id, 'uid=', '');
CREATE INDEX idx_oio_user_id ON swissid_logs_prod.orig_identity_owner(user_id);

-- insert Kurt Stockinger
INSERT INTO swissid_logs_prod.orig_identity_owner (ldap_id,user_id,email,firstname,gender,lastname,name,consent,phone_number) VALUES ('uid=f5798c02-8278-4c64-b5fe-43d49b610cf9,ou=people,dc=swisssign,dc=com','f5798c02-8278-4c64-b5fe-43d49b610cf9','Kurt.Stockinger@zhaw.ch','Kurt','male','Stockinger','Kurt Stockinger','','+41589344979');
