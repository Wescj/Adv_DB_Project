-- ===========================================================
-- FILE: master_setup.sql
-- PURPOSE: Install all Eggshell database components
-- ===========================================================

SET ECHO ON
SET SERVEROUTPUT ON SIZE 1000000
SET TIMING ON
SET LINESIZE 200
SET PAGESIZE 100
WHENEVER SQLERROR CONTINUE

PROMPT =====================================================================
PROMPT EGGSHELL HOME BUILDER - MASTER SETUP
PROMPT =====================================================================

PROMPT Phase 1: Creating tables and constraints...
@DDL_Script_1.0.ddl

PROMPT Phase 2: Loading initial data...
@data_init.sql

PROMPT Phase 3: Creating views...
@View.sql
@View2.sql

PROMPT Phase 4: Creating functions...
@Function.sql

PROMPT Phase 5: Creating triggers...
@Trigger1.sql
@Trigger2.sql
@Trigger3.sql
@Trigger4.sql

PROMPT Phase 6: Implementing surrogate keys...
@buyer_surrogate.sql

PROMPT Phase 7: Creating packages and procedures...
@Package.sql
@Procedure1.sql
@Procedure2.sql

PROMPT Phase 8: Creating indexes and denormalization...
@alternate_index.sql
@denormalization.sql

PROMPT Phase 9: Creating roles and permissions...
@roles.sql

PROMPT Phase 10: Creating scheduled job...
@create_sql_script_job.sql

PROMPT 
PROMPT =====================================================================
PROMPT SETUP COMPLETE - Run verify_eggshell.sql to check installation
PROMPT =====================================================================

SET TIMING OFF