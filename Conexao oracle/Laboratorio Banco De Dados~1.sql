create or replace PROCEDURE INSERIR_SHOWS_LISTED (

  p_sli_lin_id "shows_listed_in"."sli_lin_id"%TYPE,
  p_sli_sho_id "shows_listed_in"."sli_sho_id"%TYPE
  
)
IS
  
BEGIN
   
    INSERT INTO "shows_listed_in"
    VALUES (p_sli_lin_id, p_sli_sho_id);
    COMMIT;
END;