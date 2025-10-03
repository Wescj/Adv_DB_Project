-- ===========================================================
-- FILE: alternate_index.sql
-- PURPOSE: Create three composite indexes for performance optimization
-- INDEX 1: housetask(house_house_id, stage) - for construction queries
-- INDEX 2: sale(employee_employee_id, "Date") - for sales reports
-- INDEX 3: decorator_choice(decorator_session_id, price) - for decorator sessions
-- ===========================================================

CREATE INDEX idx_housetask_house_stage 
ON housetask(house_house_id, stage);

CREATE INDEX idx_sale_employee_date 
ON sale(employee_employee_id, "Date");

CREATE INDEX idx_decorator_choice_session 
ON decorator_choice(decorator_session_id, price);

COMMIT;

-- Verify creation
SELECT index_name, table_name, status
FROM user_indexes
WHERE index_name IN ('IDX_HOUSETASK_HOUSE_STAGE', 
                     'IDX_SALE_EMPLOYEE_DATE',
                     'IDX_DECORATOR_CHOICE_SESSION')
ORDER BY table_name, index_name;