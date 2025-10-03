-- ===========================================================
-- FILE: master_setup.sql
-- PURPOSE: Execute all Eggshell database components in correct order
-- DEPENDENCY: Runs all component scripts in proper sequence
-- ===========================================================

SET ECHO ON
SET SERVEROUTPUT ON SIZE 1000000
SET TIMING ON
SET LINESIZE 200
SET PAGESIZE 100
WHENEVER SQLERROR CONTINUE

PROMPT =====================================================================
PROMPT EGGSHELL HOME BUILDER - MASTER SETUP SCRIPT
PROMPT Installing all database components in dependency order...
PROMPT =====================================================================

-- =====================================================================
-- Phase 1: Core Schema (Tables and Constraints)
-- =====================================================================
PROMPT 
PROMPT Phase 1: Creating tables and constraints...
@DDL_Script_1.0.ddl
--@renamed_Script.ddl

-- =====================================================================
-- Phase 2: Initial Data Load
-- =====================================================================
PROMPT 
PROMPT Phase 2: Loading initial data...
@data_init.sql

-- =====================================================================
-- Phase 3: Views (Read-Only Components)
-- =====================================================================
PROMPT 
PROMPT Phase 3: Creating views...
@View.sql
@View2.sql
@View3.sql

-- =====================================================================
-- Phase 4: Functions (Reusable Logic)
-- =====================================================================
PROMPT 
PROMPT Phase 4: Creating functions...
@Function.sql

-- =====================================================================
-- Phase 5: Triggers (Data Integrity and Automation)
-- =====================================================================
PROMPT 
PROMPT Phase 5: Creating triggers...
@Trigger1.sql
@Trigger2.sql
@Trigger3.sql
@Trigger4.sql
@Trigger5.sql

-- =====================================================================
-- Phase 6: Surrogate Key Implementation
-- =====================================================================
PROMPT 
PROMPT Phase 6: Implementing surrogate keys...
@buyer_surrogate.sql

-- =====================================================================
-- Phase 7: Packages and Procedures
-- =====================================================================
PROMPT 
PROMPT Phase 7: Creating packages and procedures...
@Package.sql
@Procedure1.sql
@Procedure2.sql

-- =====================================================================
-- Phase 8: Performance Optimizations
-- =====================================================================
PROMPT 
PROMPT Phase 8: Creating indexes and denormalization...
@alternate_index.sql
@denormalization.sql

-- =====================================================================
-- Phase 9: Security (Roles and Permissions)
-- =====================================================================
PROMPT 
PROMPT Phase 9: Creating roles and permissions...
@roles.sql

PROMPT 
PROMPT =====================================================================
PROMPT SETUP COMPLETE
PROMPT =====================================================================
PROMPT All components have been installed.
PROMPT Run verify_eggshell.sql to check installation status.
PROMPT =====================================================================

SET TIMING OFF