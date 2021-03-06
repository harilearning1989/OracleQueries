CREATE TABLE countries(
    country_id NUMBER GENERATED BY DEFAULT AS IDENTITY,
    country_name VARCHAR2(100) NOT NULL,
    alpha2 char(2),
    alpha3 char(3),
    country_code NUMBER(10,0),
    region VARCHAR2(100),
    sub_region VARCHAR2(100),
    intermediate_region VARCHAR2(100),
    region_code NUMBER(10,0),
    sub_region_code NUMBER(10,0),
    intermediate_region_code NUMBER(10,0),
    CONSTRAINT country_id_PK PRIMARY KEY(country_id)
);

create table countries_bkp as select * from countries;