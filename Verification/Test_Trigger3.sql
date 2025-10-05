-- 1. Check what price the view currently shows for the option and stage
SELECT * 
FROM v_current_option_price
WHERE option_option_id = 16001 AND stage = 2;

-- 2. Pick an existing decorator session at stage 2
SELECT decoratorsession_id, stage
FROM decorator_session
WHERE decoratorsession_id = 14001;

-- 3. Insert a decorator choice WITHOUT setting price
INSERT INTO decorator_choice (
  decoratorchoice_id,
  item,
  description,
  decorator_session_id,
  option_option_id
) VALUES (
  99901,                      -- new ID
  'Test Granite AutoPrice',
  'Trigger autoprice verification',
  14001,                      -- session stage = 2
  16001                       
);

COMMIT;

-- 4. Verify the result
SELECT decoratorchoice_id, item, price, decorator_session_id, option_option_id
FROM decorator_choice
WHERE decoratorchoice_id = 99901;