-- ===========================================================
-- FILE: scheduled_run.sql
-- PURPOSE: Non-interactive script to orchestrate a complete database
--          installation and test for automated execution.
-- WORKFLOW: Clean -> Setup -> Verify -> Test
-- NOTE: This script has all PAUSE commands removed for the scheduler.
-- ===========================================================

SET ECHO ON
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 200
SET PAGESIZE 100
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

PROMPT =====================================================================
PROMPT EGGSHELL - AUTOMATED INSTALLATION AND TEST WORKFLOW
PROMPT =====================================================================
PROMPT This script will:
PROMPT 1. Clean existing objects
PROMPT 2. Run complete database setup
PROMPT 3. Verify all objects are installed correctly
PROMPT 4. Run functional tests
PROMPT =====================================================================

-- =====================================================================
-- Step 1: Cleanup
-- =====================================================================
PROMPT
PROMPT =====================================================================
PROMPT STEP 1: CLEANUP - Removing any existing Eggshell objects...
PROMPT =====================================================================

@cleanup.sql

-- =====================================================================
-- Step 2: Master Setup
-- =====================================================================
PROMPT
PROMPT =====================================================================
PROMPT STEP 2: MASTER SETUP - Installing all database components...
PROMPT =====================================================================

@master_setup.sql

-- =====================================================================
-- Step 3: Verification
-- =====================================================================
PROMPT
PROMPT =====================================================================
PROMPT STEP 3: VERIFICATION - Checking all objects exist and are valid...
PROMPT =====================================================================

@verify_eggshell.sql

-- =====================================================================
-- Step 4: Run Tests
-- =====================================================================
PROMPT
PROMPT =====================================================================
PROMPT STEP 4: FUNCTIONAL TESTS - Running test suites...
PROMPT =====================================================================

@test_alternate_index.sql
@test_denormalization.sql

PROMPT =====================================================================
PROMPT AUTOMATED WORKFLOW COMPLETE
PROMPT =====================================================================