-- ===========================================================
-- Procedure: pr_add_choice
-- Purpose:
--   Simplifies inserting a decorator choice by hiding the OUT parameter
--   and printing the generated ID using DBMS_OUTPUT.
-- pr_add_choice is a convenient front door into the option-pricing logic. 
-- You give it a session, option, and some labels, and it inserts a properly-priced decorator choice for you.
-- Parameters:
--   p_session_id  - ID of the decorator_session (must exist).
--   p_option_id   - ID of the Option selected.
--   p_item        - Display item name (e.g., "Garage Sink").
--   p_desc        - Optional description of the choice.
-- Notes:
--   - The actual price is auto-filled by trg_decorator_choice_autoprice
--     or pkg_eggshell’s pricing logic.
-- ===========================================================
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE pr_add_choice(
  p_session_id  IN NUMBER,
  p_option_id   IN NUMBER,
  p_item        IN VARCHAR2,
  p_desc        IN VARCHAR2
) AS
  v_id NUMBER;  
BEGIN
  -- Call the package procedure; OUT id returned into v_id
  pkg_eggshell.add_decorator_choice(p_session_id, p_option_id, p_item, p_desc, v_id);

  -- Print a confirmation message
  DBMS_OUTPUT.PUT_LINE('Decorator choice inserted with id='||v_id);
END;
/

