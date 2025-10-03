-- ===========================================================
-- MASTER SETUP SCRIPT
-- Eggshell Home Builder Database
-- Executes all components in correct dependency order
-- ===========================================================

SET ECHO ON
SET SERVEROUTPUT ON SIZE 1000000
SET TIMING ON
WHENEVER SQLERROR CONTINUE

-- Phase 1: Core Schema and Data
@/Users/msj/Adv_DB_Project/DDL_Script_1.0.ddl
@/Users/msj/Adv_DB_Project/data_init.sql

-- Phase 2: Views
@/Users/msj/Adv_DB_Project/View.sql

-- Phase 3: Functions
@/Users/msj/Adv_DB_Project/Function.sql

-- Phase 4: Triggers
@/Users/msj/Adv_DB_Project/Trigger1.sql
@/Users/msj/Adv_DB_Project/Trigger2.sql
@/Users/msj/Adv_DB_Project/Trigger3.sql

-- Phase 5: Surrogate Keys
@/Users/msj/Adv_DB_Project/buyer_surrogate.sql

-- Phase 6: Packages
@/Users/msj/Adv_DB_Project/Package.sql

-- Phase 7: Performance Optimizations
@/Users/msj/Adv_DB_Project/alternate_index.sql
@/Users/msj/Adv_DB_Project/denormalization.sql

-- Phase 8: Security
@/Users/msj/Adv_DB_Project/roles.sql

-- Verification
SELECT object_type, object_name, status 
FROM user_objects 
WHERE object_type IN ('TABLE', 'VIEW', 'TRIGGER', 'FUNCTION', 'PACKAGE', 'SEQUENCE', 'INDEX') 
ORDER BY object_type, object_name;

SELECT object_type, object_name, status 
FROM user_objects 
WHERE status = 'INVALID' 
ORDER BY object_type, object_name;

SELECT object_type, COUNT(*) as total_count, 
       SUM(CASE WHEN status = 'VALID' THEN 1 ELSE 0 END) as valid_count, 
       SUM(CASE WHEN status = 'INVALID' THEN 1 ELSE 0 END) as invalid_count 
FROM user_objects 
WHERE object_type IN ('TABLE', 'VIEW', 'TRIGGER', 'FUNCTION', 'PACKAGE', 'SEQUENCE', 'INDEX') 
GROUP BY object_type 
ORDER BY object_type;

SET TIMING OFF