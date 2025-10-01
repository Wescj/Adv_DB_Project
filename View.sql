-- =========================================
-- Option Categories
-- =========================================
INSERT INTO optioncategory (category_id, categoryname)
VALUES (10, 'Electrical');

INSERT INTO optioncategory (category_id, categoryname)
VALUES (20, 'Plumbing');

-- =========================================
-- Options
-- =========================================
-- Electrical option: Ceiling Fan Wiring
INSERT INTO "Option" (option_id, option_name, description, optioncategory_category_id, housestyle_style_id)
VALUES (1001, 'Ceiling Fan Wiring', 'Pre-wire for ceiling fan', 10, 3001);

-- Plumbing option: Garage Sink
INSERT INTO "Option" (option_id, option_name, description, optioncategory_category_id, housestyle_style_id)
VALUES (1002, 'Garage Sink', 'Utility sink in garage', 20, 3001);

-- =========================================
-- Option Stage Prices
-- =========================================
-- Ceiling Fan Wiring at Stage 4
INSERT INTO option_stage_price (osp_id, option_option_id, stage, cost, revision_date)
VALUES (5001, 1001, 4, 125, DATE '2024-01-01');

INSERT INTO option_stage_price (osp_id, option_option_id, stage, cost, revision_date)
VALUES (5002, 1001, 4, 150, DATE '2024-06-01'); -- later revision (should be picked)

-- Ceiling Fan Wiring at Stage 7
INSERT INTO option_stage_price (osp_id, option_option_id, stage, cost, revision_date)
VALUES (5003, 1001, 7, 350, DATE '2024-01-01');

INSERT INTO option_stage_price (osp_id, option_option_id, stage, cost, revision_date)
VALUES (5004, 1001, 7, 375, DATE '2024-07-15'); -- later revision (should be picked)

-- Garage Sink at Stage 1
INSERT INTO option_stage_price (osp_id, option_option_id, stage, cost, revision_date)
VALUES (5005, 1002, 1, 450, DATE '2024-01-01');

INSERT INTO option_stage_price (osp_id, option_option_id, stage, cost, revision_date)
VALUES (5006, 1002, 1, 500, DATE '2024-09-01'); -- later revision (should be picked)

COMMIT;


CREATE OR REPLACE VIEW v_current_option_price AS
SELECT option_option_id,
       stage,
       MAX(revision_date) KEEP (DENSE_RANK LAST ORDER BY revision_date) AS latest_revision_date,
       MAX(cost)          KEEP (DENSE_RANK LAST ORDER BY revision_date) AS current_cost
FROM option_stage_price
GROUP BY option_option_id, stage;



SELECT * FROM v_current_option_price ORDER BY option_option_id, stage;