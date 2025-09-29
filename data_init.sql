-- =============================
-- 1. Subdivision & School
-- =============================
INSERT INTO subdivision (subdivision_id, name, city, state, zip)
VALUES (1, 'Sunnyvale', 'Pittsburgh', 'PA', '15213');

INSERT INTO school (school_id, name, address, type, subdivision_subdivision_id)
VALUES (1, 'Lincoln High', '123 Main St', 'High School', 1);

-- =============================
-- 2. Lot & HouseStyle & Elevation
-- =============================
INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (1, '456 Oak Ave', 'Pittsburgh', 'PA', '15213', 5000, 'Corner lot', 15000, 1);

INSERT INTO housestyle (style_id, stylename, baseprice, styledescription, "Size", photo, numberwindows, ceiling)
VALUES (1, 'Modern Ranch', 250000, 'Open layout with patio', 2000, EMPTY_BLOB(), 10, 'Vaulted');

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (1, 'E1', 'Basic elevation', 'None', 1);

-- =============================
-- 3. House
-- =============================
INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (1, 1, DATE '2026-01-01', 1, 1, 1);

-- =============================
-- 4. Bank & Bank Worker
-- =============================
INSERT INTO bank (bank_id, name, address, zip, state, phone_number)
VALUES (1, 'First National Bank', '101 Finance St', '15213', 'PA', '412-555-1111');

INSERT INTO bank_worker (worker_id, name, phone_number, fax_number, bank_bank_id)
VALUES (1, 'Alice Smith', '412-555-2222', '412-555-3333', 1);

-- =============================
-- 5. Employee
-- =============================
INSERT INTO employee (employee_id, name, title, email, phone, active, hire_date, license_number)
VALUES (1, 'Bob Johnson', 'Site Manager', 'bob.j@company.com', '412-555-4444', 'Y', SYSDATE, 'LIC123');

-- =============================
-- 6. Buyer & Escrow Agent
-- =============================
INSERT INTO buyer (buyer_id, name, address, city, state, zip, phone, email)
VALUES (1, 'Carol White', '789 Maple St', 'Pittsburgh', 'PA', '15213', '412-555-5555', 'carol@example.com');

INSERT INTO escrowagent (escrowagent_id, name, address, city, state, zip, phone_number)
VALUES (1, 'Secure Escrow LLC', '202 Market St', 'Pittsburgh', 'PA', '15213', '412-555-6666');

-- =============================
-- 7. Housetask & Construction Task
-- =============================
INSERT INTO housetask (housetask_id, stage, required, plannedstart, plannedend, notes, house_house_id,
                       employee_employee_id, plannedcost, actualcost, percent_complete)
VALUES (1, 1, 'Y', DATE '2025-10-01', DATE '2025-11-01', 'Foundation work', 1, 1, 20000, 18000, 0.90);

INSERT INTO construction_task (task_id, description, stage, basecost, approval, housetask_housetask_id)
VALUES (1, 'Lay foundation', 1, 20000, 'Y', 1);

-- =============================
-- 8. Decorator Session & Choice
-- =============================
INSERT INTO decorator_session (decoratorsession_id, "Date", stage, housetask_housetask_id, approval)
VALUES (1, SYSDATE, 2, 1, 'Y');

INSERT INTO optioncategory (category_id, categoryname)
VALUES (1, 'Flooring');

INSERT INTO "Option" (option_id, option_name, description, optioncategory_category_id, housestyle_style_id)
VALUES (1, 'Hardwood Floor', 'Oak wood planks', 1, 1);

INSERT INTO decorator_choice (decoratorchoice_id, item, description, price, decorator_session_id, option_option_id)
VALUES (1, 'Flooring', 'Dark oak finish', 8000, 1, 1);

-- =============================
-- 9. Task Progress & Photo
-- =============================
INSERT INTO task_progress (progress_id, percentage_complete, estimatedcompletiondate, housetask_housetask_id)
VALUES (1, 50, DATE '2025-11-15', 1);

INSERT INTO photo (photo_id, date_uploaded, url, housetask_housetask_id, task_progress_progress_id)
VALUES (1, SYSDATE, 'http://example.com/photo1.jpg', 1, 1);

-- =============================
-- 10. Rooms
-- =============================
INSERT INTO rooms (room_id, name, "Size", floor, no_of_windows, notes, house_house_id, housestyle_style_id, ceilings)
VALUES (1, 'Living Room', 400, '1st', 4, 'Spacious area', 1, 1, 'High ceiling');

-- =============================
-- 11. Sale
-- =============================
INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, estimatedcompletion,
                  receivedsubdivision, receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, employee_employee_id,
                  house_house_id, bank_worker_worker_id)
VALUES (1, SYSDATE, 'Mortgage', 50000, DATE '2026-01-01',
        'Y', 'Y', 'Y', 1, 1, 1, 1, 1);

COMMIT;
