-- ===========================================================
-- FILE: verify_eggshell.sql
-- PURPOSE: Verify all Eggshell database objects exist and are valid
-- USE CASE: Run after master_setup.sql to check installation
-- ===========================================================

SET ECHO OFF
SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

PROMPT =====================================================================
PROMPT EGGSHELL HOME BUILDER - DATABASE VERIFICATION
PROMPT Checking all objects for existence and validity...
PROMPT =====================================================================

-- =====================================================================
-- Check 1: Tables (Expected: 22)
-- =====================================================================
PROMPT 
PROMPT ====== Check 1: Tables (Expected: 22) ======

SELECT COUNT(*) AS table_count
FROM user_tables 
WHERE table_name IN (
    'BANK', 'BANK_WORKER', 'BUYER', 'CONSTRUCTION_TASK', 
    'DECORATOR_CHOICE', 'DECORATOR_SESSION', 'ELEVATION', 'EMPLOYEE', 
    'ESCROWAGENT', 'HOUSE', 'HOUSESTYLE', 'HOUSETASK', 
    'LOT', 'OPTION', 'OPTION_STAGE_PRICE', 'OPTIONCATEGORY', 
    'PHOTO', 'ROOMS', 'SALE', 'SCHOOL', 'SUBDIVISION', 'TASK_PROGRESS'
);

SELECT table_name 
FROM user_tables 
WHERE table_name IN (
    'BANK', 'BANK_WORKER', 'BUYER', 'CONSTRUCTION_TASK', 
    'DECORATOR_CHOICE', 'DECORATOR_SESSION', 'ELEVATION', 'EMPLOYEE', 
    'ESCROWAGENT', 'HOUSE', 'HOUSESTYLE', 'HOUSETASK', 
    'LOT', 'OPTION', 'OPTION_STAGE_PRICE', 'OPTIONCATEGORY', 
    'PHOTO', 'ROOMS', 'SALE', 'SCHOOL', 'SUBDIVISION', 'TASK_PROGRESS'
)
ORDER BY table_name;

-- =====================================================================
-- Check 2: Views (Expected: 4)
-- =====================================================================
PROMPT 
PROMPT ====== Check 2: Views (Expected: 4) ======

SELECT COUNT(*) AS view_count
FROM user_objects 
WHERE object_type = 'VIEW' 
  AND object_name IN (
      'V_CURRENT_OPTION_PRICE', 
      'V_SALES_SUMMARY', 
      'V_CONSTRUCTION_PROGRESS',
      'V_HOUSE_STYLE_DETAILS'
  );

SELECT object_name, status 
FROM user_objects 
WHERE object_type = 'VIEW' 
  AND object_name IN (
      'V_CURRENT_OPTION_PRICE', 
      'V_SALES_SUMMARY', 
      'V_CONSTRUCTION_PROGRESS',
      'V_HOUSE_STYLE_DETAILS'
  )
ORDER BY object_name;

-- =====================================================================
-- Check 3: Function (Expected: 1)
-- =====================================================================
PROMPT 
PROMPT ====== Check 3: Function (Expected: 1) ======

SELECT COUNT(*) AS function_count
FROM user_objects 
WHERE object_type = 'FUNCTION' 
  AND object_name = 'FN_HOUSE_TOTAL_PRICE';

SELECT object_name, status 
FROM user_objects 
WHERE object_type = 'FUNCTION' 
  AND object_name = 'FN_HOUSE_TOTAL_PRICE';

-- =====================================================================
-- Check 4: Package (Expected: 1 package + 1 body = 2)
-- =====================================================================
PROMPT 
PROMPT ====== Check 4: Package (Expected: 2 - spec and body) ======

SELECT COUNT(*) AS package_count
FROM user_objects 
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY') 
  AND object_name = 'PKG_EGGSHELL';

SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY') 
  AND object_name = 'PKG_EGGSHELL' 
ORDER BY object_type;

-- =====================================================================
-- Check 5: Procedures (Expected: 2)
-- =====================================================================
PROMPT 
PROMPT ====== Check 5: Procedures (Expected: 2) ======

SELECT COUNT(*) AS procedure_count
FROM user_objects 
WHERE object_type = 'PROCEDURE' 
  AND object_name IN ('PR_ADD_CHOICE', 'PR_RECORD_PROGRESS');

SELECT object_name, status 
FROM user_objects 
WHERE object_type = 'PROCEDURE' 
  AND object_name IN ('PR_ADD_CHOICE', 'PR_RECORD_PROGRESS')
ORDER BY object_name;

-- =====================================================================
-- Check 6: Triggers (Expected: 8)
-- =====================================================================
PROMPT 
PROMPT ====== Check 6: Triggers (Expected: 8) ======

SELECT COUNT(*) AS trigger_count
FROM user_triggers 
WHERE trigger_name IN (
    'TRG_TASKPROG_VALIDATE', 
    'TRG_HOUSE_STAGE_AUTOADVANCE', 
    'TRG_DECORATOR_CHOICE_AUTOPRICE',
    'TRG_SESSION_VALIDATE_STAGE',
    'TRG_CHOICE_SET_PRICE',
    'TRG_SALE_CALC_TOTAL', 
    'TRG_DECORATOR_UPDATE_SALE', 
    'BUYER_BIR'
);

SELECT trigger_name, status, table_name 
FROM user_triggers 
WHERE trigger_name IN (
    'TRG_TASKPROG_VALIDATE', 
    'TRG_HOUSE_STAGE_AUTOADVANCE', 
    'TRG_DECORATOR_CHOICE_AUTOPRICE',
    'TRG_SESSION_VALIDATE_STAGE',
    'TRG_CHOICE_SET_PRICE',
    'TRG_SALE_CALC_TOTAL', 
    'TRG_DECORATOR_UPDATE_SALE', 
    'BUYER_BIR'
)
ORDER BY trigger_name;

-- =====================================================================
-- Check 7: Sequences (Expected: 1)
-- =====================================================================
PROMPT 
PROMPT ====== Check 7: Sequences (Expected: 1) ======

SELECT COUNT(*) AS sequence_count
FROM user_sequences 
WHERE sequence_name = 'BUYER_SEQ';

SELECT sequence_name, last_number 
FROM user_sequences 
WHERE sequence_name = 'BUYER_SEQ';

-- =====================================================================
-- Check 8: Indexes (Expected: 3 alternate indexes)
-- =====================================================================
PROMPT 
PROMPT ====== Check 8: Alternate Indexes (Expected: 3) ======

SELECT COUNT(*) AS index_count
FROM user_indexes 
WHERE index_name IN (
    'IDX_HOUSETASK_HOUSE_STAGE',
    'IDX_SALE_EMPLOYEE_DATE',
    'IDX_DECORATOR_CHOICE_SESSION'
);

SELECT index_name, table_name, uniqueness, status 
FROM user_indexes 
WHERE index_name IN (
    'IDX_HOUSETASK_HOUSE_STAGE',
    'IDX_SALE_EMPLOYEE_DATE',
    'IDX_DECORATOR_CHOICE_SESSION'
)
ORDER BY index_name;

-- =====================================================================
-- Check 9: Denormalization Column (Expected: 1)
-- =====================================================================
PROMPT 
PROMPT ====== Check 9: Denormalized Column (Expected: 1) ======

SELECT COUNT(*) AS column_count
FROM user_tab_columns 
WHERE table_name = 'SALE' 
  AND column_name = 'TOTAL_CONTRACT_PRICE';

SELECT column_name, data_type, nullable 
FROM user_tab_columns 
WHERE table_name = 'SALE' 
  AND column_name = 'TOTAL_CONTRACT_PRICE';

-- =====================================================================
-- Check 10: Roles (Expected: 2)
-- =====================================================================
PROMPT 
PROMPT ====== Check 10: Roles (Expected: 2) ======

SELECT COUNT(*) AS role_count
FROM dba_roles 
WHERE role IN ('SALES_ROLE', 'CONSTRUCTION_ROLE');

SELECT role 
FROM dba_roles 
WHERE role IN ('SALES_ROLE', 'CONSTRUCTION_ROLE')
ORDER BY role;

-- =====================================================================
-- Check 11: Invalid Objects (Expected: 0)
-- =====================================================================
PROMPT 
PROMPT ====== Check 11: Invalid Objects (Expected: 0) ======

SELECT COUNT(*) AS invalid_count
FROM user_objects 
WHERE status = 'INVALID';

SELECT object_type, object_name, status 
FROM user_objects 
WHERE status = 'INVALID' 
ORDER BY object_type, object_name;

-- =====================================================================
-- Summary Report
-- =====================================================================
PROMPT 
PROMPT =====================================================================
PROMPT VERIFICATION SUMMARY
PROMPT =====================================================================

SELECT 
    'Tables' AS object_type, 
    22 AS expected,
    (SELECT COUNT(*) FROM user_tables WHERE table_name IN (
        'BANK', 'BANK_WORKER', 'BUYER', 'CONSTRUCTION_TASK', 
        'DECORATOR_CHOICE', 'DECORATOR_SESSION', 'ELEVATION', 'EMPLOYEE', 
        'ESCROWAGENT', 'HOUSE', 'HOUSESTYLE', 'HOUSETASK', 
        'LOT', 'OPTION', 'OPTION_STAGE_PRICE', 'OPTIONCATEGORY', 
        'PHOTO', 'ROOMS', 'SALE', 'SCHOOL', 'SUBDIVISION', 'TASK_PROGRESS'
    )) AS actual,
    CASE WHEN (SELECT COUNT(*) FROM user_tables WHERE table_name IN (
        'BANK', 'BANK_WORKER', 'BUYER', 'CONSTRUCTION_TASK', 
        'DECORATOR_CHOICE', 'DECORATOR_SESSION', 'ELEVATION', 'EMPLOYEE', 
        'ESCROWAGENT', 'HOUSE', 'HOUSESTYLE', 'HOUSETASK', 
        'LOT', 'OPTION', 'OPTION_STAGE_PRICE', 'OPTIONCATEGORY', 
        'PHOTO', 'ROOMS', 'SALE', 'SCHOOL', 'SUBDIVISION', 'TASK_PROGRESS'
    )) = 22 THEN 'PASS' ELSE 'FAIL' END AS status
FROM dual
UNION ALL
SELECT 
    'Views', 4,
    (SELECT COUNT(*) FROM user_objects WHERE object_type = 'VIEW' AND object_name IN (
        'V_CURRENT_OPTION_PRICE', 'V_SALES_SUMMARY', 'V_CONSTRUCTION_PROGRESS',
        'V_HOUSE_STYLE_DETAILS'
    )),
    CASE WHEN (SELECT COUNT(*) FROM user_objects WHERE object_type = 'VIEW' AND object_name IN (
        'V_CURRENT_OPTION_PRICE', 'V_SALES_SUMMARY', 'V_CONSTRUCTION_PROGRESS',
        'V_HOUSE_STYLE_DETAILS'
    )) = 4 THEN 'PASS' ELSE 'FAIL' END
FROM dual
UNION ALL
SELECT 
    'Function', 1,
    (SELECT COUNT(*) FROM user_objects WHERE object_type = 'FUNCTION' AND object_name = 'FN_HOUSE_TOTAL_PRICE'),
    CASE WHEN (SELECT COUNT(*) FROM user_objects WHERE object_type = 'FUNCTION' AND object_name = 'FN_HOUSE_TOTAL_PRICE') = 1 THEN 'PASS' ELSE 'FAIL' END
FROM dual
UNION ALL
SELECT 
    'Package (spec+body)', 2,
    (SELECT COUNT(*) FROM user_objects WHERE object_type IN ('PACKAGE', 'PACKAGE BODY') AND object_name = 'PKG_EGGSHELL'),
    CASE WHEN (SELECT COUNT(*) FROM user_objects WHERE object_type IN ('PACKAGE', 'PACKAGE BODY') AND object_name = 'PKG_EGGSHELL') = 2 THEN 'PASS' ELSE 'FAIL' END
FROM dual
UNION ALL
SELECT 
    'Procedures', 2,
    (SELECT COUNT(*) FROM user_objects WHERE object_type = 'PROCEDURE' AND object_name IN ('PR_ADD_CHOICE', 'PR_RECORD_PROGRESS')),
    CASE WHEN (SELECT COUNT(*) FROM user_objects WHERE object_type = 'PROCEDURE' AND object_name IN ('PR_ADD_CHOICE', 'PR_RECORD_PROGRESS')) = 2 THEN 'PASS' ELSE 'FAIL' END
FROM dual
UNION ALL
SELECT 
    'Triggers', 8,
    (SELECT COUNT(*) FROM user_triggers WHERE trigger_name IN (
        'TRG_TASKPROG_VALIDATE', 'TRG_HOUSE_STAGE_AUTOADVANCE', 'TRG_DECORATOR_CHOICE_AUTOPRICE',
        'TRG_SESSION_VALIDATE_STAGE', 'TRG_CHOICE_SET_PRICE', 'TRG_SALE_CALC_TOTAL', 
        'TRG_DECORATOR_UPDATE_SALE', 'BUYER_BIR'
    )),
    CASE WHEN (SELECT COUNT(*) FROM user_triggers WHERE trigger_name IN (
        'TRG_TASKPROG_VALIDATE', 'TRG_HOUSE_STAGE_AUTOADVANCE', 'TRG_DECORATOR_CHOICE_AUTOPRICE',
        'TRG_SESSION_VALIDATE_STAGE', 'TRG_CHOICE_SET_PRICE', 'TRG_SALE_CALC_TOTAL', 
        'TRG_DECORATOR_UPDATE_SALE', 'BUYER_BIR'
    )) = 8 THEN 'PASS' ELSE 'FAIL' END
FROM dual
UNION ALL
SELECT 
    'Sequences', 1,
    (SELECT COUNT(*) FROM user_sequences WHERE sequence_name = 'BUYER_SEQ'),
    CASE WHEN (SELECT COUNT(*) FROM user_sequences WHERE sequence_name = 'BUYER_SEQ') = 1 THEN 'PASS' ELSE 'FAIL' END
FROM dual
UNION ALL
SELECT 
    'Indexes', 3,
    (SELECT COUNT(*) FROM user_indexes WHERE index_name IN (
        'IDX_HOUSETASK_HOUSE_STAGE', 'IDX_SALE_EMPLOYEE_DATE', 'IDX_DECORATOR_CHOICE_SESSION'
    )),
    CASE WHEN (SELECT COUNT(*) FROM user_indexes WHERE index_name IN (
        'IDX_HOUSETASK_HOUSE_STAGE', 'IDX_SALE_EMPLOYEE_DATE', 'IDX_DECORATOR_CHOICE_SESSION'
    )) = 3 THEN 'PASS' ELSE 'FAIL' END
FROM dual
UNION ALL
SELECT 
    'Denorm Column', 1,
    (SELECT COUNT(*) FROM user_tab_columns WHERE table_name = 'SALE' AND column_name = 'TOTAL_CONTRACT_PRICE'),
    CASE WHEN (SELECT COUNT(*) FROM user_tab_columns WHERE table_name = 'SALE' AND column_name = 'TOTAL_CONTRACT_PRICE') = 1 THEN 'PASS' ELSE 'FAIL' END
FROM dual;

PROMPT 
PROMPT =====================================================================
PROMPT If all statuses show PASS, the installation is complete and correct.
PROMPT If any show FAIL, review the detailed checks above.
PROMPT =====================================================================