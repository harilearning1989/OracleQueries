CREATE OR REPLACE PACKAGE test_pkg AS
   PROCEDURE in_only_test (inParam1 IN VARCHAR2);
   PROCEDURE in_and_out_test (inParam1 IN VARCHAR2, outParam1 OUT VARCHAR2);
END test_pkg;
/
CREATE OR REPLACE PACKAGE BODY test_pkg AS
   PROCEDURE in_only_test(inParam1 IN VARCHAR2) AS
   BEGIN
      DBMS_OUTPUT.PUT_LINE('in_only_test');
   END in_only_test;
   PROCEDURE in_and_out_test(inParam1 IN VARCHAR2, outParam1 OUT VARCHAR2) AS
   BEGIN
      outParam1 := 'Woohoo Im an outparam, and this is my inparam ' || inParam1;
   END in_and_out_test;
END test_pkg;


@Entity
@Table(name = "MYTABLE")
@NamedStoredProcedureQueries({
   @NamedStoredProcedureQuery(name = "in_only_test", 
                              procedureName = "test_pkg.in_only_test",
                              parameters = {
                                 @StoredProcedureParameter(mode = ParameterMode.IN, name = "inParam1", type = String.class)
                              }),
   @NamedStoredProcedureQuery(name = "in_and_out_test", 
                              procedureName = "test_pkg.in_and_out_test",
                              parameters = {
                                 @StoredProcedureParameter(mode = ParameterMode.IN, name = "inParam1", type = String.class),
                                 @StoredProcedureParameter(mode = ParameterMode.OUT, name = "outParam1", type = String.class)
                              })
})
public class MyTable implements Serializable {
}

public interface MyTableRepository extends CrudRepository<MyTable, Long> {
    @Procedure(name = "in_only_test")
    void inOnlyTest(@Param("inParam1") String inParam1);
    @Procedure(name = "in_and_out_test")
    String inAndOutTest(@Param("inParam1") String inParam1);
 }