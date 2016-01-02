-- Load the premier CSV file into the
load data local infile '~/Premier.csv'
into table HolderTable
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;


-- Undergo the second etl below
load data local infile '~/ETL2.csv'
into table HolderTable
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;
