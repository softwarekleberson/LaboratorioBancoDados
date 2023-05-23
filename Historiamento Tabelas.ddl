
CREATE TABLE h_casting (
    hcas_id          INTEGER NOT NULL,
    HCAS_NAME     VARCHAR2(600),
    HCAS_DT_HIST DATE NOT NULL
);


ALTER TABLE h_casting ADD CONSTRAINT hcasting_pk PRIMARY KEY ( hcas_id,
                                                               HCAS_DT_HIST);

CREATE TABLE h_countries (
    hcon_id      INTEGER NOT NULL,
    hcon_name    VARCHAR2(600),
    hcon_dt_hist DATE NOT NULL
);

ALTER TABLE h_countries ADD CONSTRAINT hcountries_pk PRIMARY KEY ( hcon_id,
                                                                   hcon_dt_hist );

CREATE TABLE h_directors (
    hdir_id      INTEGER NOT NULL,
    hdir_name    VARCHAR2(600),
    hdir_dt_hist DATE NOT NULL
);


ALTER TABLE h_directors ADD CONSTRAINT hdirectors_pk PRIMARY KEY ( hdir_id,
                                                                   hdir_dt_hist );

CREATE TABLE h_listed_in (
    hlin_id      INTEGER NOT NULL,
    hlin_name    VARCHAR2(600),
    hlin_dt_hist DATE NOT NULL
);

ALTER TABLE h_listed_in ADD CONSTRAINT hlisted_in_pk PRIMARY KEY ( hlin_id,
                                                                   hlin_dt_hist );

CREATE TABLE h_rating (
    HRAT_ID         INTEGER NOT NULL,
    hrat_classification VARCHAR2(600),
    HRAT_DT_HIST     DATE NOT NULL
);


ALTER TABLE h_rating ADD CONSTRAINT hrating_pk PRIMARY KEY ( HRAT_ID,
                                                             HRAT_DT_HIST);

CREATE TABLE h_shows (
    hsho_id           INTEGER NOT NULL,
    hsho_title        VARCHAR2(600),
    hsho_release_year INTEGER,
    hsho_date_added   VARCHAR2(600),
    hsho_duration     VARCHAR2(600),
    hsho_description  CLOB,
    HSHO_TPE_ID   INTEGER NOT NULL,
    hsho_rat_id       INTEGER NOT NULL,
    HSHO_DT_HIST  DATE NOT NULL
);


ALTER TABLE h_shows ADD CONSTRAINT hshows_pk PRIMARY KEY ( hsho_id,
                                                           HSHO_DT_HIST);

CREATE TABLE h_type (
    HTPE_ID       INTEGER NOT NULL,
    HTPE_TYPE     VARCHAR2(60),
    HTPE_DT_HIST  DATE NOT NULL
);

ALTER TABLE h_type ADD CONSTRAINT htype_pk PRIMARY KEY (HTPE_ID,
                                                        HTPE_DT_HIST);


