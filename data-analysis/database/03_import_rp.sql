
-- duration less than 1 sec
truncate table orig_relying_party;

LOAD DATA INFILE '/tmp/export_rp_prod_2019_12_11.csv' INTO TABLE orig_relying_party
fields terminated by '\t'
enclosed by '"'
lines terminated by '\n'
IGNORE 1 LINES
(@uuid,@name)
SET
client_id = nullif(@uuid,''),
client_name = nullif(@name,'')
