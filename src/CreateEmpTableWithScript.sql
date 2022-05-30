CREATE TABLE "F8_DBA"."TEST_EMPLOYEE" 
   ("EMP_ID" NUMBER GENERATED BY DEFAULT AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 
   					INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOT NULL ENABLE, 
	"FIRST_NAME" VARCHAR2(50) NOT NULL ENABLE, 
	"LAST_NAME" VARCHAR2(50), 
	"EDUCATION" VARCHAR2(50), 
	"AGE" NUMBER(*,0), 
	"SALARY" FLOAT(126), 	
	"GRADE" NUMBER(*,0), 
	"GRADE_NAME" CHAR(2), 
	"DOB" DATE, 
	"CREATED_AT" TIMESTAMP (6) WITH TIME ZONE, 
	"UPDATED_AT" TIMESTAMP (6) WITH TIME ZONE, 
	 CONSTRAINT "TEST_EMPLOYEE_PK" PRIMARY KEY ("EMP_ID")  
   );
 
--===================================================================
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-Mon-YYYY HH24:MI:SS';
--=====================================================================

DECLARE 
 FIRST_NAME TEST_EMPLOYEE.FIRST_NAME%TYPE;
 LAST_NAME TEST_EMPLOYEE.LAST_NAME%TYPE;
 education TEST_EMPLOYEE.EDUCATION%TYPE;

 TYPE education_type 
        IS TABLE OF VARCHAR2(100) 
        INDEX BY BINARY_INTEGER;
 education_type_tmp education_type;
 start_value integer := 1; 
 end_value integer := 200; 
 age integer := 0;
 salary float := 0.0;

 year  number;
 month  number;
 day  number;
 dob Date;

TYPE emp_grades IS TABLE OF INTEGER;
grades emp_grades;

TYPE grade_names IS TABLE OF VARCHAR2(10);
names grade_names;

total integer;
emp_grade integer;
   
BEGIN
	
	education_type_tmp(1) := 'MBA';
	education_type_tmp(2) := 'MCA';
	education_type_tmp(3) := 'BTech';
	education_type_tmp(4) := 'BSC';
	education_type_tmp(5) := 'BCA';
	education_type_tmp(6) := 'Mech';
	education_type_tmp(7) := 'Network'; 

    grades:= emp_grades(1, 2, 3, 4, 5);
    names := grade_names('E1', 'E2', 'E3', 'B1', 'B2'); 

    total := names.count;
  FOR i IN start_value..end_value
  LOOP 
    select 'Duddukunta' || trunc(dbms_random.value(1,1000)),'Hari' || trunc(dbms_random.value(1,1000)),
    education_type_tmp(trunc(dbms_random.value(1,7))),trunc(dbms_random.value(1,100)),
    trunc(dbms_random.value(10000,100000),2)
    INTO FIRST_NAME,LAST_NAME,education,age,salary  from dual;    
  
  SELECT TO_DATE(
         TRUNC(
           DBMS_RANDOM.VALUE(
             TO_CHAR(DATE '1980-01-01','J'),
             TO_CHAR(DATE '2010-12-31','J')
           )
         ),
         'J'
       )
       + NUMTODSINTERVAL(
           FLOOR(DBMS_RANDOM.VALUE(0,86399)),
           'SECOND'
         ) AS dob_temp INTO dob
	FROM DUAL;

	emp_grade := trunc(dbms_random.value(1,6));
	DBMS_OUTPUT.PUT_LINE( 'Duddukunta' || FIRST_NAME ||'==='|| 'Hari' || LAST_NAME||'==education=='||education
   	||'===Age=='||age||'===Salary==='||salary||'===DOB==='||dob||'===Grade==='||grades(emp_grade)||'===Name==='||names(emp_grade));
  
  INSERT INTO F8_DBA.TEST_EMPLOYEE(FIRST_NAME,LAST_NAME,EDUCATION,AGE,SALARY,DOB,CREATED_AT,UPDATED_AT,grade,grade_name) 
  values(FIRST_NAME,LAST_NAME,education,age,salary,dob,SYSTIMESTAMP,SYSTIMESTAMP,grades(emp_grade),names(emp_grade));
  END LOOP;
END;

==========================================================================
--ALTER TABLE F8_DBA.TEST_EMPLOYEE ADD(grade integer,grade_name char(2));
--COMMIT;

--alter table F8_DBA.TEST_EMPLOYEE Rename column greade TO grade;
--COMMIT;