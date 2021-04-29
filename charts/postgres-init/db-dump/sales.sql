CREATE TABLE sales (
   id integer,
   price numeric,
   type character varying(20),
   notes text
);

INSERT INTO sales VALUES('1', '1.23', 'Buy', 'Test buy');
INSERT INTO sales VALUES('2', '666', 'Sell', 'Test sell');
INSERT INTO sales VALUES('3', '1.666', 'Buy', 'Real buy');
INSERT INTO sales VALUES('4', '1024.123', 'Buy', 'Real buy');
INSERT INTO sales VALUES('5', '666.66', 'Sell', 'Real sell');
