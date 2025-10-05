CREATE OR REPLACE VIEW v_current_option_price AS
SELECT option_option_id,
       stage,
       MAX(revision_date) KEEP (DENSE_RANK LAST ORDER BY revision_date) AS latest_revision_date,
       MAX(cost)          KEEP (DENSE_RANK LAST ORDER BY revision_date) AS current_cost
FROM option_stage_price
GROUP BY option_option_id, stage;
