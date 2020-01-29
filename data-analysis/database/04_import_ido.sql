
-- duration about 25 sec
truncate table orig_identity_owner;

LOAD DATA INFILE '/tmp/export_ido_prod_2019_12_11.csv' INTO TABLE orig_identity_owner
fields terminated by '\t'
enclosed by '"'
lines terminated by '\n'
