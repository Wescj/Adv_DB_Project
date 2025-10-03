-- ===========================================================
-- VERIFICATION SCRIPT - Eggshell Objects Only
-- ===========================================================

SET LINESIZE 200
SET PAGESIZE 100

PROMPT =====================================================================
PROMPT EGGSHELL HOME BUILDER - DATABASE VERIFICATION
PROMPT =====================================================================

PROMPT
PROMPT --- Tables (Should be 22) ---
SELECT table_name, num_rows FROM user_tables WHERE table_name IN ('BANK', 'BANK_WORKER', 'BUYER', 'CONSTRUCTION_TASK', 'DECORATOR_CHOICE', 'DECORATOR_SESSION', 'ELEVATION', 'EMPLOYEE', 'ESCROWAGENT', 'HOUSE', 'HOUSESTYLE', 'HOUSETASK', 'LOT', 'OPTION', 'OPTION_STAGE_PRICE', 'OPTIONCATEGORY', 'PHOTO', 'ROOMS', 'SALE', 'SCHOOL', 'SUBDIVISION', 'TASK_PROGRESS') ORDER BY table_name;

PROMPT
PROMPT --- Views (Should be 3) ---
SELECT object_name, status FROM user_objects WHERE object_type = 'VIEW' AND object_name IN ('V_CURRENT_OPTION_PRICE', 'V_SALES_SUMMARY', 'V_CONSTRUCTION_PROGRESS') ORDER BY object_name;

PROMPT
PROMPT --- Function (Should be 1) ---
SELECT object_name, status FROM user_objects WHERE object_type = 'FUNCTION' AND object_name = 'FN_HOUSE_TOTAL_PRICE';

PROMPT
PROMPT --- Package (Should be 1 + body) ---
SELECT object_name, object_type, status FROM user_objects WHERE object_type IN ('PACKAGE', 'PACKAGE BODY') AND object_name = 'PKG_EGGSHELL' ORDER BY object_type;

PROMPT
PROMPT --- Triggers (Should be 6) ---
SELECT trigger_name, status, table_name FROM user_triggers WHERE trigger_name IN ('TRG_TASKPROG_VALIDATE', 'TRG_HOUSE_STAGE_AUTOADVANCE', 'TRG_DECORATOR_CHOICE_AUTOPRICE', 'TRG_SALE_CALC_TOTAL', 'TRG_DECORATOR_UPDATE_SALE', 'BUYER_BIR') ORDER BY trigger_name;

PROMPT
PROMPT --- Sequences (Should be 1) ---
SELECT sequence_name, last_number FROM user_sequences WHERE sequence_name = 'BUYER_SEQ';

PROMPT
PROMPT --- Index (Should be 1) ---
SELECT index_name, table_name, uniqueness FROM user_indexes WHERE index_name = 'IDX_HOUSETASK_HOUSE_STAGE';

PROMPT
PROMPT --- Denormalization Column (Should exist) ---
SELECT column_name, data_type, nullable FROM user_tab_columns WHERE table_name = 'SALE' AND column_name = 'TOTAL_CONTRACT_PRICE';

PROMPT
PROMPT =====================================================================
PROMPT SUMMARY: Check counts above match expected values
PROMPT Tables: 22 | Views: 3 | Function: 1 | Package: 1 | Triggers: 6 | Sequences: 1 | Index: 1
PROMPT =====================================================================