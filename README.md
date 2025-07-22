# Netflix Database and Auditing Project

## Overview
This project involves the creation of an auditing system and a database called Netflix. The goal is to audit update and delete operations on the main database tables, as well as to store detailed information about shows, actors, directors, production countries, categories, and ratings.

## Project Structure

### File `AUDITORIA.txt`

1. **Creating the AUDITORIA User**
    ```sql
    ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

    CREATE USER AUDITORIA IDENTIFIED BY 123
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON USERS;
    
    GRANT CONNECT, RESOURCE TO AUDITORIA;
    ```

2. **Creating the `SEQ_AUD` Sequence**
    ```sql
    CREATE SEQUENCE "SEQ_AUD" MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE NOORDER NOCYCLE NOKEEP NOSCALE GLOBAL;
    ```

3. **Creating the Audit Table `AUDITORIA`**
    ```sql
    CREATE TABLE "AUDITORIA" (
        "AUD_ID" NUMBER(6,0), 
        "AUD_TABELA" VARCHAR2(30), 
        "AUD_ROWID" VARCHAR2(20), 
        "AUD_OPERACAO" CHAR(1), 
        "AUD_COLUNA" VARCHAR2(30), 
        "AUD_VALOR_ANTIGO" VARCHAR2(255), 
        "AUD_VALOR_NOVO" VARCHAR2(255), 
        "AUD_USU_BD" VARCHAR2(30), 
        "AUD_USU_SO" VARCHAR2(255), 
        "AUD_DATA" DATE
    );
    ```

4. **Creating the Trigger `TG_SEQ_AUD`**
    ```sql
    CREATE OR REPLACE NONEDITIONABLE TRIGGER "TG_SEQ_AUD" 
    BEFORE INSERT ON AUDITORIA
    FOR EACH ROW
    BEGIN
        :NEW.AUD_ID := SEQ_AUD.NEXTVAL;
    END;
    /
    ALTER TRIGGER "TG_SEQ_AUD" ENABLE;
    ```

5. **Creating the Procedure `PROC_AUDITORIA`**
    ```sql
    CREATE OR REPLACE NONEDITIONABLE PROCEDURE "PROC_AUDITORIA" (
        P_AUD_TABELA IN VARCHAR,
        P_AUD_ROWID IN VARCHAR,
        P_AUD_OPERACAO IN CHAR,
        P_AUD_COLUNA IN VARCHAR,
        P_AUD_VALOR_ANTIGO IN VARCHAR,
        P_AUD_VALOR_NOVO IN VARCHAR,
        P_AUD_USU_BD IN VARCHAR, 
        P_AUD_USU_SO IN VARCHAR, 
        P_AUD_DATA IN DATE
    ) IS
    BEGIN
        INSERT INTO AUDITORIA VALUES (null, P_AUD_TABELA, P_AUD_ROWID, P_AUD_OPERACAO, P_AUD_COLUNA, P_AUD_VALOR_ANTIGO, P_AUD_VALOR_NOVO, P_AUD_USU_BD, P_AUD_USU_SO, P_AUD_DATA);
    END;
    /
    ```

6. **Granting Privileges**
    ```sql
    GRANT EXECUTE ON AUDITORIA.PROC_AUDITORIA TO app;
    ```

### File `BancoCompleto.txt`

1. **Creating Sequences**
    ```sql
    CREATE SEQUENCE "APP"."SEQ_CAS" MINVALUE 1 MAXVALUE 9999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE NOORDER NOCYCLE NOKEEP NOSCALE GLOBAL;
    -- Sequences for other tables: SEQ_COU, SEQ_DIR, SEQ_LIN, SEQ_RAT, SEQ_SHO, SEQ_TPE
    ```

2. **Creating Tables**
    ```sql
    CREATE TABLE "APP"."casting" ("cas_id" INTEGER, "cas_name" VARCHAR2(600));
    CREATE TABLE "APP"."countries" ("con_id" INTEGER, "con_name" VARCHAR2(600));
    CREATE TABLE "APP"."directors" ("dir_id" INTEGER, "dir_name" VARCHAR2(600));
    CREATE TABLE "APP"."listed_in" ("lin_id" INTEGER, "lin_name" VARCHAR2(600));
    CREATE TABLE "APP"."rating" ("rat_id" INTEGER, "rat_classification" VARCHAR2(60));
    CREATE TABLE "APP"."shows" (
        "sho_id" INTEGER, "sho_title" VARCHAR2(600), "sho_release_year" INTEGER, 
        "sho_date_added" VARCHAR2(600), "sho_duration" VARCHAR2(600), 
        "sho_description" CLOB, "sho_tpe_id" INTEGER, "sho_rat_id" INTEGER
    );
    -- Relationship tables: shows_casting, shows_countries, shows_directors, shows_listed_in
    CREATE TABLE "APP"."type" ("tpe_id" INTEGER, "tpe_type" VARCHAR2(10));
    ```

3. **Creating Sequence Triggers**
    ```sql
    CREATE OR REPLACE NONEDITIONABLE TRIGGER "APP"."TG_SEQ_CAS"
    BEFORE INSERT ON "casting"
    FOR EACH ROW
    BEGIN
        :NEW."cas_id" := SEQ_CAS.nextval;
    END;
    /
    ALTER TRIGGER "APP"."TG_SEQ_CAS" ENABLE;
    -- Triggers for other tables: TG_SEQ_CON, TG_SEQ_DIR, TG_SEQ_LIN, TG_SEQ_RAT, TG_SEQ_SHO, TG_SEQ_TPE
    ```

4. **Creating Constraints**
    ```sql
    ALTER TABLE "APP"."type" ADD CONSTRAINT "pk_tpe" PRIMARY KEY ("tpe_id") USING INDEX ENABLE;
    ALTER TABLE "APP"."type" ADD CONSTRAINT "CK_TPE_01" CHECK("tpe_type" IS NOT NULL) ENABLE;
    -- Constraints for other tables: shows, rating, listed_in, casting, countries, directors, shows_casting, shows_countries, shows_directors, shows_listed_in
    ```

5. **Insertion Procedures**
    ```sql
    CREATE OR REPLACE PROCEDURE INSERIR_CASTING (p_cas_name "casting"."cas_name"%type) IS
        v_id integer;
        v_count integer;
    BEGIN
        SELECT count(*) into v_count from "casting" where "cas_name" = p_cas_name;
        if v_count = 0 then
            INSERT INTO "casting" VALUES (0, p_cas_name);
        end if;
        SELECT "cas_id" into v_id from "casting" WHERE "casting"."cas_name" = p_cas_name;
        UPDATE metflix set cast = v_id where cast = p_cas_name;
        COMMIT;
    END INSERIR_CASTING;
    /
    -- Procedures for other tables: INSERIR_COUNTRIES, INSERIR_DIRECTORS, INSERIR_LISTED, INSERIR_RATING, INSERIR_SHOWS, INSERIR_SHOWS_CASTING, INSERIR_SHOWS_COUNTRIES, INSERIR_SHOWS_DIRECTORS, INSERIR_SHOWS_LISTED, INSERIR_TYPES
    ```

6. **PL/SQL to Call Procedures**
    ```sql
    DECLARE
        CURSOR cur_CASTING IS SELECT CAST FROM METFLIX;
    BEGIN
        FOR linha_cur_CASTING IN cur_CASTING LOOP
            INSERIR_CASTING(linha_cur_CASTING.CAST);
        END LOOP;
    END;
    -- PL/SQL for other tables: TYPE, RATING, LISTED-IN, DIRECTORS, COUNTRIES, SHOWS, SHOWS_CASTING, SHOWS_COUNTRIES, SHOWS_DIRECTORS, SHOWS_LISTED_IN
    ```

7. **Creating History Tables**
    ```sql
    CREATE TABLE h_casting (
        hcas_id INTEGER NOT NULL,
        HCAS_NAME VARCHAR2(600),
        HCAS_DT_HIST DATE NOT NULL
    );
    ALTER TABLE h_casting ADD CONSTRAINT hcasting_pk PRIMARY KEY ( hcas_id, HCAS_DT_HIST);
    -- History tables for: h_countries, h_directors, h_listed_in, h_rating, h_shows, h_type
    ```

8. **Audit Triggers**
    ```sql
    CREATE OR REPLACE NONEDITIONABLE TRIGGER "TG_AUD_CASTING" 
    AFTER UPDATE OR DELETE ON H_CASTING
    FOR EACH ROW
    DECLARE
        V_USU_BD VARCHAR(30);
        V_USU_SO VARCHAR(255) := SYS_CONTEXT('USERENV','OS_USER');
        V_TP_OPERACAO CHAR(1);
        V_ROWID VARCHAR(20);
        V_TABELA VARCHAR(30) := 'H_CASTING';
    BEGIN
        SELECT USER INTO V_USU_BD FROM DUAL;
        V_ROWID := :OLD.ROWID;
        IF DELETING THEN
            V_TP_OPERACAO := 'D';
            AUDITORIA.PROC_AUDITORIA(V_TABELA, V_ROWID, V_TP_OPERACAO, NULL, NULL, NULL, V_USU_BD, V_USU_SO, SYSDATE);
        ELSE
            V_TP_OPERACAO := 'U';
            -- Additional audit logic here
        END IF;
    END;
    /
    ```

## How to Use

1. **Create the AUDITORIA User**
    - Run the SQL script at the beginning of the `AUDITORIA.txt` file to create the AUDITORIA user and grant necessary privileges.

2. **Create Tables and Sequences**
    - Run the SQL scripts in the `BancoCompleto.txt` file to create all required tables, sequences, and relationships.

3. **Configure Triggers and Procedures**
    - Set up the audit and insertion triggers and procedures as described. These scripts are responsible for maintaining change history and data consistency.

4. **Insert Data**
    - Use the insertion procedures to add data into the tables. The procedures ensure consistent data and proper updates to related tables.

5. **Auditing and History**
    - The audit triggers will automatically activate on UPDATE and DELETE operations, recording changes in the history and audit tables.

## Conclusion
This project establishes a robust structure for managing and auditing data in the Netflix database. The implementation of triggers and procedures ensures that all operations are tracked and a detailed history of changes is maintained.
