-- CASTING
DECLARE
    CURSOR cur_CASTING IS SELECT CAST FROM  METFLIX;
BEGIN
    FOR linha_cur_CASTING IN cur_CASTING LOOP
        INSERIR_CASTING(linha_cur_CASTING.CAST);
    END LOOP;
END;


--TYPE
DECLARE 
    CURSOR cur_Types IS SELECT DISTINCT TYPE FROM METFLIX;
BEGIN
    FOR linha_cur_types IN cur_Types LOOP
        INSERIR_TYPES(linha_cur_types.TYPE);
    END LOOP;
END;



--RATING
DECLARE
    CURSOR cur_RATINGS IS SELECT DISTINCT RATING FROM METFLIX;
BEGIN
    FOR linha_cur_ratings IN cur_RATINGS LOOP
        INSERIR_RATING(linha_cur_ratings.RATING);
    END LOOP;
END;



--LISTED-IN
DECLARE
    CURSOR cur_LISTEDS IS SELECT LISTED_IN FROM METFLIX;
BEGIN
    FOR linha_cur_LISTEDS IN cur_LISTEDS LOOP
        INSERIR_LISTED(linha_cur_LISTEDS.LISTED_IN);
    END LOOP;
END;



--DIRECTORS
DECLARE
    CURSOR cur_DIRECTORS IS SELECT DIRECTOR FROM METFLIX;
BEGIN
    FOR linha_cur_DIRECTORS IN cur_DIRECTORS LOOP
        INSERIR_DIRECTOR(linha_cur_DIRECTORS.DIRECTOR);
    END LOOP;
END;


-- COUNTRIES
DECLARE
    CURSOR cur_COUNTRIES IS SELECT COUNTRY FROM METFLIX;
BEGIN
    FOR linha_cur_COUNTRIES IN cur_COUNTRIES LOOP
        INSERIR_COUNTRIES(linha_cur_COUNTRIES.COUNTRY);
    END LOOP;
END;


-- SHOWS
DECLARE
    CURSOR cur_SHOWS IS SELECT TITLE, RELEASE_YEAR, DATE_ADDED, DURATION, DESCRIPTION, TYPE, RATING FROM METFLIX;
BEGIN
    FOR linha_cur_shows IN cur_SHOWS LOOP
        INSERIR_SHOWS(linha_cur_shows.TITLE, linha_cur_shows.RELEASE_YEAR,
                      linha_cur_shows.DATE_ADDED, linha_cur_shows.DURATION,
                      linha_cur_shows.DESCRIPTION,
                      linha_cur_shows.TYPE,
                      linha_cur_shows.RATING);
    END LOOP;
END;


-- Update na TABELA METFLIX, ALTERANDO A COLUNA TYPE. 
-- NESSA ATUALIZA��O O VALOR DA COLUNA � SUBSTITUIDO PELO SEU ID NA TABELA TYPE, COLUNA TPE_ID

UPDATE metflix
SET type = (
  SELECT "tpe_id"
  FROM "type"
  WHERE metflix.type = "type"."tpe_type"
);

-- UPDATE NA TABELA METFLIX, ALTERANDO A COLUNA RATING.
-- NESSA ATUALZA��O O VALOR DA COLUNA � SUBSTITUIDO PELO SEU ID NA TABELA RATING, COLUNA RAT_ID
UPDATE metflix
SET rating = (
    SELECT "rat_id"
    FROM "rating"
    WHERE metflix.rating = "rating"."rat_classification"
);


-- SHOWS_CASTING
DECLARE
    CURSOR cur_SHOWS_CASTING IS SELECT CAST, TITLE FROM METFLIX;
BEGIN
    FOR linha_cur IN cur_SHOWS_CASTING LOOP
        INSERIR_SHOWS_CASTING(linha_cur.CAST, linha_cur.TITLE);
    END LOOP;
END;

-- SHOWS_COUNTRIES
DECLARE
    CURSOR cur_SHOWS_COUTRIES IS SELECT TITLE, COUNTRY FROM METFLIX;
BEGIN
    FOR linha_cur IN cur_SHOWS_COUTRIES LOOP
        INSERIR_SHOWS_COUNTRIES(linha_cur.TITLE, linha_cur.COUNTRY);
    END LOOP;
END;


--SHOWS_DIRECTORS
DECLARE 
    CURSOR cur_SHOWS_DIRECTORS IS SELECT TITLE, DIRECTOR FROM METFLIX;
BEGIN
    FOR linha_cur IN cur_SHOWS_DIRECTORS LOOP
        INSERIR_SHOWS_DIRECTORS(linha_cur.TITLE, linha_cur.DIRECTOR);
    END LOOP;
END;


--SHOWS_LISTED_IN
DECLARE
    CURSOR cur_SHOWS_LISTED IS SELECT title, listed_in FROM METFLIX;
BEGIN
    FOR linha_cur IN cur_SHOWS_LISTED LOOP
        INSERIR_SHOWS_LISTED(linha_cur.listed_in, linha_cur.title);
    END LOOP;
END;
        
 




