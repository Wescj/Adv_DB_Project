-- ===========================================================
-- FILE: test_file_run.sql
-- PURPOSE: Orchestrate complete database installation and testing
-- WORKFLOW: Clean → Setup → Verify → Test
-- ===========================================================

SET ECHO ON
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 200
SET PAGESIZE 100

PROMPT =====================================================================
PROMPT EGGSHELL HOME BUILDER - COMPLETE INSTALLATION AND TEST WORKFLOW
PROMPT =====================================================================
PROMPT This script will:
PROMPT 1. Clean existing objects (if any)
PROMPT 2. Run complete database setup
PROMPT 3. Verify all objects are installed correctly
PROMPT 4. Run functional tests
PROMPT =====================================================================

PAUSE Press Enter to begin installation, or Ctrl+C to cancel...

-- =====================================================================
-- Step 1: Cleanup (Optional - Comment out if not needed)
-- =====================================================================
PROMPT 
PROMPT =====================================================================
PROMPT STEP 1: CLEANUP
PROMPT Removing any existing Eggshell objects...
PROMPT =====================================================================

@cleanup.sql

PROMPT 
PROMPT Cleanup complete. Pausing for review...
PAUSE Press Enter to continue with setup...

-- =====================================================================
-- Step 2: Master Setup
-- =====================================================================
PROMPT 
PROMPT =====================================================================
PROMPT STEP 2: MASTER SETUP
PROMPT Installing all database components...
PROMPT =====================================================================

@master_setup.sql

PROMPT 
PROMPT Setup complete. Pausing for review...
PAUSE Press Enter to continue with verification...

-- =====================================================================
-- Step 3: Verification
-- =====================================================================
PROMPT 
PROMPT =====================================================================
PROMPT STEP 3: VERIFICATION
PROMPT Checking all objects exist and are valid...
PROMPT =====================================================================

@verify_eggshell.sql

PROMPT 
PROMPT Verification complete. Review summary above.
PAUSE Press Enter to continue with testing...

-- =====================================================================
-- Step 4: Run Tests
-- =====================================================================
PROMPT 
PROMPT =====================================================================
PROMPT STEP 4: FUNCTIONAL TESTS
PROMPT Running test suites...
PROMPT =====================================================================

PROMPT 
PROMPT --- Test Suite 1: Alternate Index Tests ---
@test_alternate_index.sql

PROMPT 
PROMPT Alternate index tests complete.
PAUSE Press Enter to run denormalization tests...

PROMPT 
PROMPT --- Test Suite 2: Denormalization Tests ---
@test_denormalization.sql

PROMPT 
PROMPT Denormalization tests complete.

-- =====================================================================
-- Final Summary
-- =====================================================================
PROMPT 
PROMPT =====================================================================
PROMPT INSTALLATION AND TESTING COMPLETE
PROMPT =====================================================================
PROMPT 
PROMPT Review the output above for:
PROMPT 1. Any errors during setup
PROMPT 2. Verification results (all should show PASS)
PROMPT 3. Test results (check for PASS/FAIL indicators)
PROMPT 
PROMPT If all tests passed, the database is ready for use.
PROMPT If any tests failed, review the specific test output for details.
PROMPT =====================================================================
