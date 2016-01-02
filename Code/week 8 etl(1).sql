/* Create ER */
/* Important: a customer can buy a specific item only once a year! */
drop table Sales1;
drop table Sales2;
drop table Customer1;
drop table Customer2;
drop table Item1;
drop table Item2;

drop table fact_sales;
drop table DimItem;
drop table DimCustomer;
drop table DimYear;

drop table customer_stage;
drop table item_stage;
drop table year_stage;
drop table fact_stage;

drop sequence c_stage_seq;
drop sequence it_stage_seq;
drop sequence year_stage_seq;

Create Table Customer1(
  c_id integer primary key,
  c_name varchar(100),
  gender integer
);


Create Table Item1(
  i_id integer primary key,
  i_name varchar(100)
);

Create Table Sales1(
  c_id integer,
  it_id integer,
  total float,
  s_date date,
  CONSTRAINT  FK_customer1 FOREIGN KEY (c_id) REFERENCES customer1,
  CONSTRAINT  FK_item1 FOREIGN KEY (it_id) REFERENCES item1,
  CONSTRAINT PK_sales1 PRIMARY KEY (it_id,c_id,s_date)
);

/* Create ER */
Create Table Customer2(
  c_id integer primary key,
  c_name varchar(100),
  gender varchar(10)
);


Create Table Item2(
  i_id integer primary key,
  i_name varchar(100)
);

Create Table Sales2(
  c_id integer,
  it_id integer,
  total float,
  s_date date,
  CONSTRAINT  FK_customer2 FOREIGN KEY (c_id) REFERENCES customer2,
  CONSTRAINT  FK_item2 FOREIGN KEY (it_id) REFERENCES item2,
  CONSTRAINT PK_sales2 PRIMARY KEY (it_id,c_id,s_date)
);

/* customer 1 */
insert into customer1 values (1,'mark',0);
insert into customer1 values (2,'mary',1);
insert into customer1 values (3,'matt',0);
insert into customer1 values (4,'john',0);
insert into customer1 values (5,'sam',0);
insert into customer1 values (6,'pat',0);
/* customer 2 */
insert into customer2 values (1,'carl','male');
insert into customer2 values (2,'jim','male');
insert into customer2 values (3,'laura','female');
insert into customer2 values (4,'sarah','female');
insert into customer2 values (5,'paul','male');
insert into customer2 values (6,'jane','female');
/* item 1 */
insert into item1 values (1,'lemon');
insert into item1 values (2,'apple');
insert into item1 values (3,'strawberry');
insert into item1 values (4,'salad');
insert into item1 values (5,'oranges');
insert into item1 values (6,'cucumber');
/*item 2 */
insert into item2 values (1,'pasta');
insert into item2 values (2,'rice');
insert into item2 values (3,'beef');
insert into item2 values (4,'lamb');
insert into item2 values (5,'bacon');
insert into item2 values (6,'hamburger');

/* sales 1 */
insert into sales1 values(1,1,200,'10-nov-2009');
insert into sales1 values(1,2,500,'10-jan-2010');
insert into sales1 values(2,3,400,'10-mar-2009');
insert into sales1 values(2,4,500,'10-mar-2011');
insert into sales1 values(3,1,700,'10-nov-2012');
insert into sales1 values(4,2,500,'10-nov-2010');
insert into sales1 values(4,4,600,'10-dec-2010');
insert into sales1 values(4,5,800,'10-nov-2010');
insert into sales1 values(5,6,600,'10-nov-2011');
insert into sales1 values(5,6,200,'10-dec-2013');
insert into sales1 values(6,1,300,'10-oct-2012');
insert into sales1 values(6,1,2500,'10-nov-2010');

/* sales 2 */
insert into sales2 values(1,4,200,'10-nov-2009');
insert into sales2 values(6,2,500,'10-jan-2010');
insert into sales2 values(2,3,400,'10-mar-2009');
insert into sales2 values(1,4,500,'10-mar-2011');
insert into sales2 values(3,1,700,'10-nov-2012');
insert into sales2 values(4,4,500,'10-nov-2010');
insert into sales2 values(4,5,600,'10-dec-2010');
insert into sales2 values(6,6,800,'10-nov-2010');
insert into sales2 values(5,1,600,'10-nov-2011');
insert into sales2 values(5,2,200,'10-dec-2013');
insert into sales2 values(4,3,300,'10-oct-2012');
insert into sales2 values(3,1,2500,'10-nov-2010');

select * from customer1;
select * from customer2;
select * from sales1;
select * from sales2;
select * from item1;
select * from item2;


/* DIMENSIONAL MODEL */
create Table DimItem(
item_sk integer primary key,
item_name varchar(100)
);

create table DimCustomer(
c_sk integer primary key,
c_name varchar(100),
gender varchar(10));

create table DimYear(
year_sk integer primary key,
year_value integer);

create table fact_sales(
item_sk integer,
c_sk integer,
year_sk integer,
total float,
CONSTRAINT  FK_dimcustomer FOREIGN KEY (c_sk) REFERENCES dimCustomer,
CONSTRAINT  FK_dimitem FOREIGN KEY (item_sk) REFERENCES DimItem,
CONSTRAINT  FK_dimyear FOREIGN KEY (year_sk) REFERENCES Dimyear,
CONSTRAINT PK_factsales PRIMARY KEY (item_sk,c_sk,year_sk));


/* INITIAL ETL */
/* Load Dimension Customers */
/* Staging Area */

create table customer_stage(
c_sk integer,
sourceDB integer,
c_id integer,
c_name varchar(100),
gender varchar(10));

create sequence c_stage_seq
start with 1
increment by 1
nomaxvalue;

drop trigger c_stage_trigger;

create trigger c_stage_trigger
before insert on customer_stage
for each row
begin
select c_stage_seq.nextval into :new.c_sk from dual;
end;

insert into customer_stage (sourcedb,c_id,c_name,gender)
select 1,c_id,c_name,cast(gender as varchar(10)) from customer1;

insert into customer_stage (sourcedb,c_id,c_name,gender)
select 2,c_id,c_name,cast(gender as varchar(10)) from customer2;

select * from customer_stage;

update customer_stage set gender='female' where gender='1';
update customer_stage set gender='male' where gender='0';

select * from customer_stage;

/*Load dimension customer */
insert into dimcustomer select c_sk,c_name,gender from customer_stage;

/* Dimension Items */
create table item_stage(
it_sk integer,
sourceDB integer,
it_id integer,
it_name varchar(100));

drop trigger it_stage_trigger;

create sequence it_stage_seq
start with 1
increment by 1
nomaxvalue;

create trigger it_stage_trigger
before insert on item_stage
for each row
begin
select it_stage_seq.nextval into :new.it_sk from dual;
end;

insert into item_stage (sourcedb,it_id,it_name)
select 1,i_id,i_name from item1;

insert into item_stage (sourcedb,it_id,it_name)
select 2,i_id,i_name from item2;

select * from item_stage;

insert into dimitem select it_sk,it_name from item_stage;

select * from dimitem;
/* end dimension item */

/* Dimension Date */
Create table year_stage(
year_sk integer primary key,
year_value integer);

create sequence year_stage_seq
start with 1
increment by 1
nomaxvalue;

drop trigger year_stage_trigger;

create trigger year_stage_trigger
before insert on year_stage
for each row
begin
select year_stage_seq.nextval into :new.year_sk from dual;
end;

insert into year_stage(year_value) select distinct cast(to_char(s_date,'YYYY') as integer)  from sales1;

select * from year_stage;

insert into year_stage(year_value) select distinct cast(to_char(s_date,'YYYY')
as integer)  from sales2 s2 where
NOT EXISTS (SELECT * FROM year_stage ys
              WHERE cast(to_char(s2.s_date,'YYYY') as integer) = ys.year_value);

select * from year_stage;

insert into DimYear select year_sk,year_value from year_stage;

/* Loading Fact */

Create table fact_stage(
c_sk integer,
it_sk integer,
year_sk integer,
c_id integer,
it_id integer,
s_date integer,
total float,
sourcedb integer
);

insert into fact_stage(c_id,it_id,s_date,total,sourcedb) select c_id,it_id,
cast(to_char(s_date,'YYYY') as integer),total,1 from Sales1;

insert into fact_stage(c_id,it_id,s_date,total,sourcedb)
select c_id,it_id,cast(to_char(s_date,'YYYY') as integer),total,2 from Sales2;

select * from fact_stage;
select * from customer_stage;

/* Assign Surrogate Keys */
/* Customer SK */
update fact_stage
set c_sk=
  (select customer_stage.c_sk from
  customer_stage  where (customer_stage.sourceDB=fact_stage.sourceDB and
  customer_stage.c_id = fact_stage.c_id));

select * from fact_stage;

/* Item SK */
update fact_stage
set it_sk=
  (select item_stage.it_sk from
  item_stage  where (item_stage.sourceDB=fact_stage.sourceDB and
  item_stage.it_id = fact_stage.it_id));

/* Date SK */
update fact_stage
set year_sk=
  (select year_stage.year_sk from
  year_stage  where (year_stage.year_value = fact_stage.s_date));

select * from fact_stage;

insert into fact_sales select it_sk,c_sk,year_sk,total from fact_stage;

select * from fact_sales;


/* END INITIAL ETL LOAD */

/* Second ETL LOAD */
/* new data in database 1 */
/* 1 new customer */
insert into customer1 values (7,'kevin',0);
/* new item 1 */
insert into item1 values (7,'tomato');
/* new sales 1 */
insert into sales1 values(7,1,200,'10-nov-2009');
insert into sales1 values(7,2,500,'10-jan-2009');
insert into sales1 values(3,7,500,'10-jan-2009');
insert into sales1 values(5,5,500,'10-jan-2011');

/* SECOND ETL */
/* recognize existing entities and update them */
/* add new entities */
/* first use stage table, then load dimensions */
/* insert only new entities. Use the c_id + sourceDB to check if entity already existed */

/* In this example, there are no matching items or customers, all the new data are new, and there is no repetition of itesm or customers among the two databases*/
/* In a complete ETL, we should check and try to match items or/and customers from the two DBs. For instance, if there is a tomato item in both the DB, it should be
merged into a single entity in the dimension*/

/* Dimension Customer */
insert into customer_stage (sourcedb,c_id,c_name,gender)
select 1,c_id,c_name,cast(gender as varchar(10)) from customer1 c1 where
NOT EXISTS (SELECT * FROM customer_stage cs
              WHERE  cs.c_id= c1.c_id and cs.sourcedb=1 );  /* updating from database 1, add only NEW customers, use the business key! */

/* Normalize new data */
update customer_stage set gender='female' where gender='1';
update customer_stage set gender='male' where gender='0';


insert into dimcustomer select c_sk,c_name,gender from customer_stage cs where
NOT EXISTS (SELECT * FROM dimcustomer
              WHERE  cs.c_sk= dimcustomer.c_sk );  /* updating only new entities */

/* Dimension Item */
insert into item_stage (sourcedb,it_id,it_name)
select 1,i_id,i_name from item1 where
NOT EXISTS (SELECT * FROM item_stage ist
              WHERE  ist.it_id= item1.i_id and ist.sourcedb=1 );  /* updating from database 1 */

insert into dimitem select it_sk,it_name from item_stage where
NOT EXISTS (SELECT * FROM dimitem di
              WHERE  item_stage.it_sk= di.item_sk );  /* updating only new entities */

/* Dimension Date */
insert into year_stage(year_value) select distinct cast(to_char(s_date,'YYYY') as integer)  from sales1 s1 where
NOT EXISTS (SELECT * FROM year_stage ys
              WHERE cast(to_char(s1.s_date,'YYYY') as integer) = ys.year_value);

insert into dimyear select year_sk,year_value from year_stage where
NOT EXISTS (SELECT * FROM dimyear dy
              WHERE  year_stage.year_sk= dy.year_sk );  /* updating only new entities */


/* Second Load Fact Table */
insert into fact_stage(c_id,it_id,s_date,total,sourcedb) select c_id,it_id,cast(to_char(s_date,'YYYY') as integer),total,1 from Sales1 s1 where
NOT EXISTS (SELECT * FROM fact_stage fs
              WHERE fs.c_id=s1.c_id and fs.it_id=s1.it_id and
			  fs.s_date=cast(to_char(s1.s_date,'YYYY') as integer)
			  and fs.sourcedb=1 );

select * from fact_stage;
/* Assign Surrogate Keys  - same sql code as before */
/* Customer SK */
update fact_stage
set c_sk=
  (select customer_stage.c_sk from
  customer_stage  where (customer_stage.sourceDB=fact_stage.sourceDB and
  customer_stage.c_id = fact_stage.c_id));

select * from fact_stage;

/* Item SK */
update fact_stage
set it_sk=
  (select item_stage.it_sk from
  item_stage  where (item_stage.sourceDB=fact_stage.sourceDB and
  item_stage.it_id = fact_stage.it_id));

/* Date SK */
update fact_stage
set year_sk=
  (select year_stage.year_sk from
  year_stage  where (year_stage.year_value = fact_stage.s_date));

select * from fact_sales;

insert into fact_sales select it_sk,c_sk,year_sk,total from fact_stage;


insert into fact_sales select it_sk,c_sk,year_sk,total from fact_stage where
NOT EXISTS (SELECT * FROM fact_sales fs
              WHERE  fact_stage.it_sk= fs.item_sk and fact_stage.c_sk= fs.c_sk and fact_stage.year_sk= fs.year_sk);  /* updating only new entities */

select * from fact_sales;

/* UPDATE FACT TABLE */
/* End of Second Load */
