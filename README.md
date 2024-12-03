# Projeto de Auditoria e Banco de Dados Netflix

## Visão Geral
Este projeto envolve a criação de um sistema de auditoria e um banco de dados chamado Netflix. O objetivo é auditar operações de atualização e exclusão nas tabelas principais do banco de dados, além de armazenar informações detalhadas sobre shows, atores, diretores, países de produção, categorias e classificações. 

## Estrutura do Projeto

### Arquivo `AUDITORIA.txt`

1. **Criação do Usuário AUDITORIA**
    ```sql
    ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

    CREATE USER AUDITORIA IDENTIFIED BY 123
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON USERS;
    
    GRANT CONNECT, RESOURCE TO AUDITORIA;
    ```

2. **Criação da Sequência `SEQ_AUD`**
    ```sql
    CREATE SEQUENCE "SEQ_AUD" MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE NOORDER NOCYCLE NOKEEP NOSCALE GLOBAL;
    ```

3. **Criação da Tabela de Auditoria `AUDITORIA`**
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

4. **Criação do Trigger `TG_SEQ_AUD`**
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

5. **Criação do Procedimento `PROC_AUDITORIA`**
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

6. **Concessão de Privilégios**
    ```sql
    GRANT EXECUTE ON AUDITORIA.PROC_AUDITORIA TO app;
    ```

### Arquivo `BancoCompleto.txt`

1. **Criação de Sequências**
    ```sql
    CREATE SEQUENCE "APP"."SEQ_CAS" MINVALUE 1 MAXVALUE 9999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE NOORDER NOCYCLE NOKEEP NOSCALE GLOBAL;
    -- Sequências para outras tabelas: SEQ_COU, SEQ_DIR, SEQ_LIN, SEQ_RAT, SEQ_SHO, SEQ_TPE
    ```

2. **Criação de Tabelas**
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
    -- Tabelas de relacionamento: shows_casting, shows_countries, shows_directors, shows_listed_in
    CREATE TABLE "APP"."type" ("tpe_id" INTEGER, "tpe_type" VARCHAR2(10));
    ```

3. **Criação de Triggers para Sequências**
    ```sql
    CREATE OR REPLACE NONEDITIONABLE TRIGGER "APP"."TG_SEQ_CAS"
    BEFORE INSERT ON "casting"
    FOR EACH ROW
    BEGIN
        :NEW."cas_id" := SEQ_CAS.nextval;
    END;
    /
    ALTER TRIGGER "APP"."TG_SEQ_CAS" ENABLE;
    -- Triggers para outras tabelas: TG_SEQ_CON, TG_SEQ_DIR, TG_SEQ_LIN, TG_SEQ_RAT, TG_SEQ_SHO, TG_SEQ_TPE
    ```

4. **Criação de Constraints**
    ```sql
    ALTER TABLE "APP"."type" ADD CONSTRAINT "pk_tpe" PRIMARY KEY ("tpe_id") USING INDEX ENABLE;
    ALTER TABLE "APP"."type" ADD CONSTRAINT "CK_TPE_01" CHECK("tpe_type" IS NOT NULL) ENABLE;
    -- Constraints para outras tabelas: shows, rating, listed_in, casting, countries, directors, shows_casting, shows_countries, shows_directors, shows_listed_in
    ```

5. **Procedimentos de Inserção**
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
    -- Procedimentos para outras tabelas: INSERIR_COUNTRIES, INSERIR_DIRECTORS, INSERIR_LISTED, INSERIR_RATING, INSERIR_SHOWS, INSERIR_SHOWS_CASTING, INSERIR_SHOWS_COUNTRIES, INSERIR_SHOWS_DIRECTORS, INSERIR_SHOWS_LISTED, INSERIR_TYPES
    ```

6. **PL/SQL para Chamada das Procedures**
    ```sql
    DECLARE
        CURSOR cur_CASTING IS SELECT CAST FROM METFLIX;
    BEGIN
        FOR linha_cur_CASTING IN cur_CASTING LOOP
            INSERIR_CASTING(linha_cur_CASTING.CAST);
        END LOOP;
    END;
    -- PL/SQL para outras tabelas: TYPE, RATING, LISTED-IN, DIRECTORS, COUNTRIES, SHOWS, SHOWS_CASTING, SHOWS_COUNTRIES, SHOWS_DIRECTORS, SHOWS_LISTED_IN
    ```

7. **Criação de Tabela de Histórico**
    ```sql
    CREATE TABLE h_casting (
        hcas_id INTEGER NOT NULL,
        HCAS_NAME VARCHAR2(600),
        HCAS_DT_HIST DATE NOT NULL
    );
    ALTER TABLE h_casting ADD CONSTRAINT hcasting_pk PRIMARY KEY ( hcas_id, HCAS_DT_HIST);
    -- Tabelas de histórico para outras tabelas: h_countries, h_directors, h_listed_in, h_rating, h_shows, h_type
    ```

8. **Triggers para Auditoria**
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
            V_TP

## Como Usar

1. **Criar o Usuário AUDITORIA**
    - Execute o script SQL presente no início do arquivo `AUDITORIA.txt` para criar o usuário AUDITORIA e conceder os privilégios necessários.

2. **Criar Tabelas e Sequências**
    - Execute os scripts SQL no arquivo `BancoCompleto.txt` para criar todas as tabelas, sequências e relacionamentos necessários.

3. **Configurar Triggers e Procedures**
    - Configure os triggers e procedures de auditoria e inserção conforme descrito nos arquivos. Esses scripts são responsáveis por manter o histórico de alterações e inserções de dados nas tabelas.

4. **Inserir Dados**
    - Utilize os procedimentos de inserção para adicionar dados nas tabelas. Os procedimentos garantem que os dados sejam consistentes e que todas as tabelas relacionadas sejam atualizadas corretamente.

5. **Auditoria e Histórico**
    - As triggers de auditoria serão ativadas automaticamente em operações de UPDATE e DELETE, registrando as alterações nas tabelas de histórico e na tabela de auditoria.

## Conclusão
Este projeto estabelece uma estrutura robusta para gerenciar e auditar dados no banco de dados Netflix. A implementação das triggers e procedures garante que todas as operações sejam registradas e que o histórico das mudanças seja mantido de forma detalhada.
