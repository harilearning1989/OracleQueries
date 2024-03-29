CREATE TABLE sys.CROP_INSURANCE(
    SERIAL_NO int NOT NULL AUTO_INCREMENT,
    MANDAL_NAME VARCHAR(100),
    VILLAGE_NAME VARCHAR(100),
    NAME_OF_THE_BENEFICIARY VARCHAR(100),
    CROP VARCHAR(100),
    EXTENT_HA int,
    CLAIM_AMOUNT_RS int,
    CATEGORY_LOANEE_NON_LOANEE VARCHAR(10),
    BANK_NAME VARCHAR(100),
    BRANCH_NAME VARCHAR(100),
    ACCOUNT_NUMBER bigint,
    CONSTRAINT SERIAL_NO_PK PRIMARY KEY (SERIAL_NO)
) ;
