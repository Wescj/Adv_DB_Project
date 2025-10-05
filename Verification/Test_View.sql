--This will show only one row per (option_option_id, stage) — the most recent revision for each pair.

SELECT * FROM v_current_option_price
ORDER BY option_option_id, stage;