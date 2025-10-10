-- ===========================================================
-- FILE: deploy_eggshell.sql
-- PURPOSE: Complete deployment workflow
-- ===========================================================

SET ECHO ON
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 200
SET PAGESIZE 100

PROMPT =====================================================================
PROMPT EGGSHELL HOME BUILDER - DEPLOYMENT
PROMPT =====================================================================

PAUSE Press Enter to begin, or Ctrl+C to cancel...

PROMPT Step 1: Cleanup...
@cleanup.sql

PAUSE Press Enter to continue...

PROMPT Step 2: Installation...
@master_setup.sql

PAUSE Press Enter to continue...

PROMPT Step 3: Verification...
@verify_eggshell.sql

PROMPT 
PROMPT =====================================================================
PROMPT DEPLOYMENT COMPLETE
PROMPT =====================================================================