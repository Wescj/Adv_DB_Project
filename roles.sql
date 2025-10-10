-- =========================================
-- Role 1: SALES_ROLE
-- For staff who handle buyers, sales, escrow, and banks
-- =========================================
CREATE ROLE staff_sales_role;

-- Grant privileges needed for managing sales workflow
GRANT SELECT, INSERT, UPDATE ON buyer       TO staff_sales_role;
GRANT SELECT, INSERT, UPDATE ON sale        TO staff_sales_role;
GRANT SELECT, INSERT, UPDATE ON escrowagent TO staff_sales_role;
GRANT SELECT, INSERT, UPDATE ON bank        TO staff_sales_role;
GRANT SELECT, INSERT, UPDATE ON bank_worker TO staff_sales_role;

CREATE OR REPLACE VIEW v_sales_summary AS
SELECT 
    s.sale_id,
    s."Date" AS sale_date,
    s.financing_method,
    s.escrowdeposit,
    b.name       AS buyer_name,
    b.phone      AS buyer_phone,
    e.name       AS employee_name,
    h.house_id   AS house_id,
    h.estimatedcompletion
FROM sale s
JOIN buyer b       ON s.buyer_buyer_id = b.buyer_id
JOIN employee e    ON s.employee_employee_id = e.employee_id
JOIN house h       ON s.house_house_id = h.house_id
JOIN escrowagent ea ON s.escrowagent_escrowagent_id = ea.escrowagent_id;

-- Grant access
GRANT SELECT ON v_sales_summary TO staff_sales_role;


-- =========================================
-- Role 2: CONSTRUCTION_ROLE
-- For staff who manage construction tasks, houses, lots, and decorator choices
-- =========================================
CREATE ROLE construction_role;

CREATE OR REPLACE VIEW v_construction_progress AS
SELECT 
    h.house_id,
    ht.housetask_id,
    ht.notes           AS task_notes,
    tp.percentage_complete,
    tp.estimatedcompletiondate,
    dc.item            AS decorator_item,
    dc.price           AS decorator_price,
    p.url              AS photo_url
FROM house h
JOIN housetask ht        ON h.house_id = ht.house_house_id
LEFT JOIN task_progress tp ON ht.housetask_id = tp.housetask_housetask_id
LEFT JOIN decorator_session ds ON ht.housetask_id = ds.housetask_housetask_id
LEFT JOIN decorator_choice dc  ON ds.decoratorsession_id = dc.decorator_session_id
LEFT JOIN photo p              ON ht.housetask_id = p.housetask_housetask_id;

-- Grant access
GRANT SELECT ON v_construction_progress TO construction_role;

-- Grant privileges needed for construction operations
GRANT SELECT, INSERT, UPDATE ON house              TO construction_role;
GRANT SELECT, INSERT, UPDATE ON lot                TO construction_role;
GRANT SELECT, INSERT, UPDATE ON housetask          TO construction_role;
GRANT SELECT, INSERT, UPDATE ON construction_task  TO construction_role;
GRANT SELECT, INSERT, UPDATE ON decorator_session  TO construction_role;
GRANT SELECT, INSERT, UPDATE ON decorator_choice   TO construction_role;
GRANT SELECT, INSERT, UPDATE ON task_progress      TO construction_role;
GRANT SELECT, INSERT, UPDATE ON photo              TO construction_role;
