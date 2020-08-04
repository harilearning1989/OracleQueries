create or replace NONEDITIONABLE PACKAGE country_items_cur_pkg AS
    PROCEDURE country_items_proc;

    TYPE rec IS RECORD (
        empno   NUMBER,
        ename   VARCHAR2(90)
    );
    TYPE tab IS
        TABLE OF rec;
    PROCEDURE prc1 (
        lv_tab OUT tab
    ); 
    
    --    calling Proc
--    DECLARE
--    ta country_items_cur_pkg.tab;
--BEGIN
--    country_items_cur_pkg.prc1(ta);
--    FOR i IN ta.first..10 LOOP dbms_output.put_line('TA:=' || ta(i).ename);
--    END LOOP;
--END;

END country_items_cur_pkg;


create or replace NONEDITIONABLE PACKAGE BODY country_items_cur_pkg AS

    PROCEDURE country_items_proc IS

        CURSOR uniq_reg_cur IS
        SELECT DISTINCT
            ( region )
        FROM
            sales_order
        WHERE
            order_date > TO_DATE('01-JAN-2010 12:00:00', 'DD-MON-YYYY HH24:MI:SS')
            AND order_date <= TO_DATE('29-JUL-2017 12:00:00', 'DD-MON-YYYY HH24:MI:SS')
        ORDER BY
            region;

        CURSOR uniq_con_cur (
            region_param sales_order.region%TYPE
        ) IS
        SELECT DISTINCT
            country
        FROM
            sales_order
        WHERE
            order_date > TO_DATE('01-JAN-2010 12:00:00', 'DD-MON-YYYY HH24:MI:SS')
            AND order_date <= TO_DATE('29-JUL-2017 12:00:00', 'DD-MON-YYYY HH24:MI:SS')
            AND region = region_param;

        reg_tmp             sales_order.region%TYPE;
        country_tmp         sales_order.country%TYPE;
        TYPE items_rec IS RECORD (
            item_type_rec   sales_order.item_type%TYPE,
            tot_type_rec    NUMBER,
            unt_sold_rec    NUMBER,
            unit_prc_rec    NUMBER,
            tot_cost_rec    NUMBER,
            tot_prft_rec    NUMBER
        );
        TYPE items_tbl IS
            TABLE OF items_rec;
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
                    item_type,
                    COUNT(item_type) tot_type,
                    SUM(units_sold) unt_sold,
                    SUM(unit_price) unit_prc,
                    SUM(total_cost) tot_cost,
                    trunc(SUM(total_profit)) tot_prft
                BULK COLLECT
                INTO items_tbl_tmp
                FROM
                    sales_order
                WHERE
                    region = reg_tmp
                    AND country = country_tmp
                GROUP BY
                    item_type
                ORDER BY
                    tot_prft DESC;
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

    PROCEDURE prc1 (
        lv_tab OUT tab
    ) IS
    BEGIN
        lv_tab := tab();
        FOR i IN (
            SELECT
                EMP_ID,
                EMP_NAME
            FROM
                employee_info
        ) LOOP
            lv_tab.extend;
            lv_tab(lv_tab.last).empno := i.EMP_ID;
            lv_tab(lv_tab.last).ename := i.EMP_NAME;
        END LOOP;

    END prc1;

END country_items_cur_pkg;