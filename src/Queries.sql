CREATE TABLE ORACLE_DEMO.EMPLOYEE_MANAGER
AS SELECT * FROM sys.employees;

SELECT emp.employee_id,emp.last_name emp_name,mngr.employee_id mngr_id,mngr.last_name manager_name 
FROM TEST_EMPLOYEES emp,TEST_EMPLOYEES mngr
WHERE emp.manager_id = mngr.employee_id;

SELECT emp.employee_id,emp.last_name emp_name,mngr.employee_id mngr_id,mngr.last_name manager_name 
FROM TEST_EMPLOYEES emp LEFT JOIN TEST_EMPLOYEES mngr
ON emp.manager_id = mngr.employee_id ORDER BY manager_name NULLS FIRST ;
