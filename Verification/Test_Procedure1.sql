SET SERVEROUTPUT ON;

BEGIN
  pr_add_choice(
    p_session_id => 14001,       -- existing decorator session at stage 2
    p_option_id  => 16001,       -- Granite Countertops
    p_item       => 'Granite Auto Test',
    p_desc       => 'Trigger-pricing verification case'
  );
END;


--Verify in the table
SELECT decoratorchoice_id,
       item,
       description,
       price,
       decorator_session_id,
       option_option_id
FROM decorator_choice
WHERE item = 'Granite Auto Test';