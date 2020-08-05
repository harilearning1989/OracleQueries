create or replace NONEDITIONABLE PACKAGE country_items_cur_pkg AS
    
    PROCEDURE country_items_proc;

    TYPE rec IS RECORD (empno   NUMBER,ename   VARCHAR2(90));
    TYPE tab IS TABLE OF rec;
    PROCEDURE prc1 (lv_tab OUT tab);

    TYPE measure_record IS RECORD (l4_id    VARCHAR2(50),l6_id VARCHAR2(50),
        l8_id    VARCHAR2(50),year NUMBER,period   NUMBER,value NUMBER);
    TYPE measure_table IS TABLE OF measure_record;
    FUNCTION get_ups (foo NUMBER) RETURN measure_table PIPELINED;
    --SELECT * FROM table(country_items_cur_pkg.get_ups(0));    
    FUNCTION sale_det_func (start_date IN varchar2,end_date IN varchar2) RETURN measure_table PIPELINED;
    
    TYPE sale_det_rec IS RECORD (item_type_rec sales_order.item_type%TYPE,tot_type_rec NUMBER,
        unt_sold_rec NUMBER,unit_prc_rec NUMBER,tot_cost_rec NUMBER,tot_prft_rec NUMBER);
    TYPE sale_tbl_tmp IS TABLE OF sale_det_rec;
    function sales_det_func (start_date VARCHAR2,end_date VARCHAR2) return sale_tbl_tmp PIPELINED;
    --SELECT * FROM table(country_items_cur_pkg.sales_det_func('start','end'));
    
    TYPE sales_country_rec IS RECORD (region_rec sales_order.REGION%TYPE,COUNTRY_rec sales_order.COUNTRY%TYPE,
    item_type_rec sales_order.item_type%TYPE,tot_type_rec NUMBER,unt_sold_rec NUMBER,unit_prc_rec NUMBER,
    tot_cost_rec NUMBER,tot_prft_rec NUMBER);
    TYPE sales_country_tbl IS TABLE OF sales_country_rec;
    function sales_country_func (start_date VARCHAR2,end_date VARCHAR2) 
    return sales_country_tbl PIPELINED;
    --SELECT * FROM table(country_items_cur_pkg.sales_country_func('start','end'));
--    SELECT * FROM table(country_items_cur_pkg.sales_country_func('start','end'));
--    SELECT REGION_REC,max(TOT_PRFT_REC) max_profit FROM table(country_items_cur_pkg.sales_country_func('start','end')) 
--    group by REGION_REC order by max_profit desc;

--SELECT * FROM table(country_items_cur_pkg.sales_country_func('25-JUL-2017 12:00:00','29-JUL-2017 12:00:00'));
    
END country_items_cur_pkg;

--Body--

CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY country_items_cur_pkg AS

    PROCEDURE country_items_proc IS
        CURSOR uniq_reg_cur IS SELECT DISTINCT ( region ) FROM sales_order
        WHERE order_date > TO_DATE('01-JAN-2010 12:00:00', 'DD-MON-YYYY HH24:MI:SS')
            AND order_date <= TO_DATE('29-JUL-2017 12:00:00', 'DD-MON-YYYY HH24:MI:SS')
        ORDER BY region;
        CURSOR uniq_con_cur (region_param sales_order.region%TYPE) IS
        SELECT DISTINCT country FROM sales_order WHERE
            order_date > TO_DATE('01-JAN-2010 12:00:00', 'DD-MON-YYYY HH24:MI:SS')
            AND order_date <= TO_DATE('29-JUL-2017 12:00:00', 'DD-MON-YYYY HH24:MI:SS')
            AND region = region_param;

        reg_tmp             sales_order.region%TYPE;
        country_tmp         sales_order.country%TYPE;
        TYPE items_rec IS RECORD (item_type_rec   sales_order.item_type%TYPE,
            tot_type_rec    NUMBER,unt_sold_rec    NUMBER,unit_prc_rec NUMBER,
            tot_cost_rec    NUMBER,tot_prft_rec    NUMBER);
        TYPE items_tbl IS TABLE OF items_rec;
        items_tbl_tmp       items_tbl;
        items_tbl_all_tmp   items_tbl := items_tbl();
    BEGIN
        OPEN uniq_reg_cur;
        LOOP
            FETCH uniq_reg_cur INTO reg_tmp;
            EXIT WHEN uniq_reg_cur%notfound;
            dbms_output.put_line('reg_tmp:=' || reg_tmp);
            OPEN uniq_con_cur(reg_tmp);
            LOOP
                FETCH uniq_con_cur INTO country_tmp;
                EXIT WHEN uniq_con_cur%notfound;
                --dbms_output.put_line('country_tmp:='||country_tmp);
                SELECT
                    item_type,COUNT(item_type) tot_type,SUM(units_sold) unt_sold,
                    SUM(unit_price) unit_prc,SUM(total_cost) tot_cost,trunc(SUM(total_profit)) tot_prft
                BULK COLLECT INTO items_tbl_tmp FROM sales_order WHERE region = reg_tmp AND country = country_tmp
                GROUP BY item_type ORDER BY tot_prft DESC;
                --dbms_output.put_line('items_tbl_tmp:='||items_tbl_tmp.count||'==uniq_con_cur rowcouunt:='||uniq_con_cur%ROWCOUNT);

                FOR i IN items_tbl_tmp.first..items_tbl_tmp.last LOOP
                    items_tbl_all_tmp.extend();
                    items_tbl_all_tmp(items_tbl_all_tmp.last) := items_tbl_tmp(i);
                END LOOP;

            END LOOP;
            CLOSE uniq_con_cur;
        END LOOP;
        CLOSE uniq_reg_cur;
        dbms_output.put_line('items_tbl_all_tmp:=' || items_tbl_all_tmp.count);
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('EXCEPTION:=' || sqlerrm);
    END country_items_proc;

    PROCEDURE prc1 (lv_tab OUT tab) IS
    BEGIN
        lv_tab := tab();
        FOR i IN (SELECT emp_id,emp_name FROM employee_info) LOOP
            lv_tab.extend;
            lv_tab(lv_tab.last).empno := i.emp_id;
            lv_tab(lv_tab.last).ename := i.emp_name;
        END LOOP;
    END prc1;

    FUNCTION get_ups (foo NUMBER) RETURN measure_table PIPELINED
    IS
        rec measure_record;
    BEGIN
        SELECT 'foo','bar','baz',2010,5,13 INTO rec FROM dual;
        PIPE ROW ( rec );
        SELECT 'foo','bar','baz',2010,5,13 INTO rec FROM dual;

        PIPE ROW ( rec );
        return;
    END get_ups;

    FUNCTION sale_det_func (start_date IN VARCHAR2,end_date IN VARCHAR2) RETURN measure_table PIPELINED
    IS
        sale_rec_tmp measure_record;
    BEGIN
        SELECT start_date,end_date,'baz',2010,5,13 INTO sale_rec_tmp FROM dual;

        PIPE ROW ( sale_rec_tmp );
        SELECT start_date,end_date,'baz',2010,5,13 INTO sale_rec_tmp FROM dual;

        PIPE ROW ( sale_rec_tmp );
        return;
    END sale_det_func;

    FUNCTION sales_det_func(start_date VARCHAR2,end_date VARCHAR2) RETURN sale_tbl_tmp PIPELINED IS
        sale_rec_tmp     sale_det_rec;
    BEGIN
        sale_rec_tmp.item_type_rec := 'ABC';
        sale_rec_tmp.tot_type_rec := 11;
        sale_rec_tmp.unt_sold_rec := 21;
        sale_rec_tmp.unit_prc_rec := 31;
        sale_rec_tmp.tot_cost_rec := 41;
        sale_rec_tmp.tot_prft_rec := 51;
        
        PIPE ROW ( sale_rec_tmp );        
        RETURN ;
        EXCEPTION WHEN OTHERS THEN
            raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);       
    END sales_det_func;
    
    FUNCTION sales_country_func(start_date VARCHAR2,end_date VARCHAR2) 
    RETURN sales_country_tbl PIPELINED IS
        sale_con_tmp     sales_country_rec;
        TYPE sales_coun_tbl IS TABLE OF sales_country_rec;
        sales_coun_tmp sales_coun_tbl;
        TYPE region_tbl IS TABLE OF sales_order.REGION%TYPE;
        region_tbl_tmp region_tbl;
        TYPE country_tbl IS TABLE OF sales_order.REGION%TYPE;
        country_tbl_tmp country_tbl;   
        sales_coun_tmp_all sales_coun_tbl := sales_coun_tbl();
        start_date_tmp varchar2(30) := start_date;--'01-JAN-2010 12:00:00';
        end_date_tmp varchar2(30) := end_date;--'29-JUL-2017 12:00:00';        
    BEGIN
        SELECT DISTINCT region bulk collect into region_tbl_tmp FROM sales_order
        WHERE order_date > TO_DATE(start_date_tmp, 'DD-MON-YYYY HH24:MI:SS')
            AND order_date <= TO_DATE(end_date_tmp, 'DD-MON-YYYY HH24:MI:SS')
        ORDER BY region;
        
        for i in region_tbl_tmp.first .. region_tbl_tmp.last loop
            SELECT DISTINCT country bulk collect into country_tbl_tmp FROM sales_order WHERE
            order_date > TO_DATE(start_date_tmp, 'DD-MON-YYYY HH24:MI:SS')
            AND order_date <= TO_DATE(end_date_tmp, 'DD-MON-YYYY HH24:MI:SS')
            AND region = region_tbl_tmp(i);
            
            for j in country_tbl_tmp.first .. country_tbl_tmp.last loop
                SELECT region_tbl_tmp(i),country_tbl_tmp(j),item_type,COUNT(item_type) tot_type,SUM(units_sold) unt_sold,
                    SUM(unit_price) unit_prc,SUM(total_cost) tot_cost,trunc(SUM(total_profit)) tot_prft
                BULK COLLECT INTO sales_coun_tmp FROM sales_order WHERE region = region_tbl_tmp(i) AND country = country_tbl_tmp(j)
                and order_date > TO_DATE(start_date_tmp, 'DD-MON-YYYY HH24:MI:SS')
                AND order_date <= TO_DATE(end_date_tmp, 'DD-MON-YYYY HH24:MI:SS')
                GROUP BY item_type ORDER BY tot_prft DESC;
                
                for k in sales_coun_tmp.first .. sales_coun_tmp.last loop
                    sales_coun_tmp_all.extend();
                    sales_coun_tmp_all(sales_coun_tmp_all.last) := sales_coun_tmp(k);
                end loop;
            end loop;
        end loop;
        for i in sales_coun_tmp_all.first .. sales_coun_tmp_all.last loop
            PIPE ROW ( sales_coun_tmp_all(i) ); 
        end loop;
               
        RETURN ;
        EXCEPTION WHEN OTHERS THEN
            raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);       
    END sales_country_func;

END country_items_cur_pkg;