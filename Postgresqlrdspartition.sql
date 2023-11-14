Create base idz-paycheck table and insert some sample records :  
--------------------------------------------------------------------

DROP TABLE IF EXISTS idz-paycheck CASCADE;
DROP SEQUENCE IF EXISTS public.paycheck_id_seq;

CREATE SEQUENCE public.paycheck_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

create table idz-paycheck
(
    payment_id int NOT NULL DEFAULT nextval('public.paycheck_id_seq'::regclass), 
    created timestamptz NOT NULL,
    updated  timestamptz NOT NULL DEFAULT now(),
    amount float,
    status varchar DEFAULT 'new'
);

CREATE INDEX idx_paycheck ON idz-paycheck (created);

INSERT INTO idz-paycheck (created) VALUES (
generate_series(timestamp '2023-01-01'
               , now()
               , interval  '5 minutes') ); 


Rename base table with new name : 
---------------------------------

ALTER TABLE idz-paycheck RENAME TO idz-paycheck_basetable;

Create Partitioned table :
--------------------------

create table idz-paycheck
(
    payment_id int NOT NULL DEFAULT nextval('public.paycheck_id_seq'::regclass), 
    created timestamptz NOT NULL,
    updated  timestamptz NOT NULL DEFAULT now(),
    amount float,
    status varchar DEFAULT 'new'
)PARTITION BY RANGE (created);

Create Separate Partition for each create date : 
------------------------------------------------

CREATE TABLE idz-paycheck_202303 PARTITION OF idz-paycheck
    FOR VALUES FROM ('2023-01-01') TO ('2023-03-01');
   
CREATE TABLE idz-paycheck_20230304 PARTITION OF idz-paycheck
    FOR VALUES FROM ('2023-03-01') TO ('2023-04-01');
    
CREATE TABLE idz-paycheck_202304 PARTITION OF idz-paycheck
    FOR VALUES FROM ('2023-04-01') TO ('2023-05-01');
    
CREATE TABLE idz-paycheck_202311 PARTITION OF idz-paycheck
    FOR VALUES FROM ('2023-05-01') TO ('2023-11-01');
   
CREATE TABLE idz-paycheck_2024 PARTITION OF idz-paycheck
    FOR VALUES FROM ('2023-11-01') TO ('2024-01-01');
	
Migrate the all records :
-------------------------
	
insert into idz-paycheck (payment_id,created,updated,amount,status) select payment_id,created,updated,amount,status from idz-paycheck_basetable;

