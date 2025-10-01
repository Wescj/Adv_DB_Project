-- =========================================
-- Subdivisions (2)
-- =========================================
INSERT INTO subdivision (subdivision_id, name, city, state, zip)
VALUES (1, 'Sunnyvale', 'Pittsburgh', 'PA', '15213');

INSERT INTO subdivision (subdivision_id, name, city, state, zip)
VALUES (2, 'Maple Grove', 'Cleveland', 'OH', '44101');

-- =========================================
-- HouseStyle & Elevations
-- =========================================
INSERT INTO housestyle (style_id, stylename, baseprice, styledescription, "Size", photo, numberwindows, ceiling)
VALUES (4001, 'Modern Ranch', 250000, 'Open layout', 2000, EMPTY_BLOB(), 10, 'Vaulted');



-- Elevations [Range: 6001–6005]
INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (6001, 'E1', 'Basic elevation', 'None', 4001);

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (6002, 'E2', 'Stone accents', 'Stone front option', 4001);

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (6003, 'E3', 'Board and batten', 'Vertical siding sketch', 4001);

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (6004, 'E4', 'Dormer windows', 'Dormer add-on', 4001);

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (6005, 'E5', 'Porch wrap', 'Porch wraparound', 4001);

--Style and Elevations for Colonial Classic

INSERT INTO housestyle (style_id, stylename, baseprice, styledescription, "Size", photo, numberwindows, ceiling)
VALUES (4002, 'Colonial Classic', 300000, 'Traditional two-story colonial design', 2400, EMPTY_BLOB(), 12, '9ft flat');

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (6006, 'E6', 'Brick front elevation', 'Brick upgrade', 4002);

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (6007, 'E7', 'Shutters and gables', 'Shutter and gable details', 4002);



-- =========================================
-- Buyers (5) [Range: 24001–24005]
-- =========================================
INSERT INTO buyer (buyer_id, name, address, city, state, zip, phone, email)
VALUES (24001, 'Carol White', '789 Maple St', 'Pittsburgh', 'PA', '15213', '412-555-5555', 'carol@example.com');

INSERT INTO buyer (buyer_id, name, address, city, state, zip, phone, email)
VALUES (24002, 'Frank Green', '999 Oak Blvd', 'Cleveland', 'OH', '44101', '216-555-6666', 'frank@example.com');

INSERT INTO buyer (buyer_id, name, address, city, state, zip, phone, email)
VALUES (24003, 'Helen Black', '23 River Ln', 'Pittsburgh', 'PA', '15214', '412-555-1111', 'helen@example.com');

INSERT INTO buyer (buyer_id, name, address, city, state, zip, phone, email)
VALUES (24004, 'Michael Gray', '7 Lake Ave', 'Cleveland', 'OH', '44102', '216-555-2222', 'michael@example.com');

INSERT INTO buyer (buyer_id, name, address, city, state, zip, phone, email)
VALUES (24005, 'Nina Brown', '14 Oak St', 'Pittsburgh', 'PA', '15215', '412-555-3333', 'nina@example.com');

-- =========================================
-- Employees (3) [Range: 26001–26003]
-- =========================================
INSERT INTO employee (employee_id, name, title, email, phone, active, hire_date, license_number)
VALUES (26001, 'Bob Johnson', 'Site Manager', 'bob.j@company.com', '412-555-4444', 'Y', SYSDATE, 'LIC123');

INSERT INTO employee (employee_id, name, title, email, phone, active, hire_date, license_number)
VALUES (26002, 'Eva Martinez', 'Engineer', 'eva.m@company.com', '216-555-7777', 'Y', SYSDATE, 'LIC456');

INSERT INTO employee (employee_id, name, title, email, phone, active, hire_date, license_number)
VALUES (26003, 'Liam Chen', 'Architect', 'liam.c@company.com', '614-555-9999', 'Y', SYSDATE, 'LIC789');

-- =========================================
-- Escrow Agents (2) [Range: 28001–28002]
-- =========================================
INSERT INTO escrowagent (escrowagent_id, name, address, city, state, zip, phone_number)
VALUES (28001, 'Secure Escrow LLC', '202 Market St', 'Pittsburgh', 'PA', '15213', '412-555-6666');

INSERT INTO escrowagent (escrowagent_id, name, address, city, state, zip, phone_number)
VALUES (28002, 'Ohio Escrow Inc', '88 River Rd', 'Cleveland', 'OH', '44101', '216-555-1234');

-- =========================================
-- Bank & Workers (1 bank [30001], 2 workers [32001–32002])
-- =========================================
INSERT INTO bank (bank_id, name, address, zip, state, phone_number)
VALUES (30001, 'First National Bank', '101 Finance St', '15213', 'PA', '412-555-1111');

INSERT INTO bank_worker (worker_id, name, phone_number, fax_number, bank_bank_id)
VALUES (32001, 'Alice Smith', '412-555-2222', '412-555-3333', 30001);

INSERT INTO bank_worker (worker_id, name, phone_number, fax_number, bank_bank_id)
VALUES (32002, 'David Brown', '216-555-8888', '216-555-9999', 30001);

-- =========================================
-- Lots (5) [Range: 2001–2005]
-- =========================================
INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (2001, '456 Oak Ave', 'Pittsburgh', 'PA', '15213', 5000, 'Corner lot', 15000, 1);

INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (2002, '22 Maple Rd', 'Cleveland', 'OH', '44101', 6000, 'Near park', 12000, 2);

INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (2003, '99 River St', 'Pittsburgh', 'PA', '15214', 4800, 'Near river', 10000, 1);

INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (2004, '11 Lake Dr', 'Cleveland', 'OH', '44102', 5500, 'Lake view', 20000, 2);

INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (2005, '5 Hilltop Ct', 'Pittsburgh', 'PA', '15216', 5200, 'On hilltop', 17000, 1);

INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (2006, '88 Colonial Way', 'Pittsburgh', 'PA', '15217', 5600, 'Quiet street near school', 18000, 1);

INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (2007, '77 Heritage Rd', 'Cleveland', 'OH', '44103', 6000, 'Large backyard lot', 20000, 2);


-- =========================================
-- Houses (5) [Range: 8001–8005]
-- =========================================
INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (8001, 1, DATE '2026-01-01', 2001, 4001, 6001);

INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (8002, 2, DATE '2026-03-15', 2002, 4001, 6002);

INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (8003, 1, DATE '2026-05-20', 2003, 4001, 6003);

INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (8004, 3, DATE '2026-07-10', 2004, 4001, 6004);

INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (8005, 2, DATE '2026-09-01', 2005, 4001, 6005);

INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (8006, 1, DATE '2026-11-01', 2006, 4002, 6006);

INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (8007, 2, DATE '2026-12-15', 2007, 4002, 6007);


-- =========================================
-- Sales (5) [Range: 34001–34005]
-- =========================================
INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, estimatedcompletion,
                  receivedsubdivision, receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, employee_employee_id,
                  house_house_id, bank_worker_worker_id)
VALUES (34001, SYSDATE, 'Mortgage', 50000, DATE '2026-01-01',
        'Y', 'Y', 'Y', 24001, 28001, 26001, 8001, 32001);

INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, estimatedcompletion,
                  receivedsubdivision, receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, employee_employee_id,
                  house_house_id, bank_worker_worker_id)
VALUES (34002, SYSDATE, 'Cash', 100000, DATE '2026-03-15',
        'Y', 'N', 'Y', 24002, 28002, 26002, 8002, 32002);

INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, estimatedcompletion,
                  receivedsubdivision, receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, employee_employee_id,
                  house_house_id, bank_worker_worker_id)
VALUES (34003, SYSDATE, 'Mortgage', 75000, DATE '2026-05-20',
        'N', 'Y', 'Y', 24003, 28001, 26003, 8003, 32001);

INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, estimatedcompletion,
                  receivedsubdivision, receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, employee_employee_id,
                  house_house_id, bank_worker_worker_id)
VALUES (34004, SYSDATE, 'Cash', 120000, DATE '2026-07-10',
        'Y', 'Y', 'N', 24004, 28002, 26002, 8004, 32002);

INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, estimatedcompletion,
                  receivedsubdivision, receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, employee_employee_id,
                  house_house_id, bank_worker_worker_id)
VALUES (34005, SYSDATE, 'Mortgage', 90000, DATE '2026-09-01',
        'Y', 'N', 'Y', 24005, 28001, 26001, 8005, 32001);

-- =========================================
-- Rooms for House 8006 (Colonial Classic, Lot 2006, Elevation 6006)
-- =========================================
INSERT INTO rooms (room_id, name, "Size", floor, no_of_windows, notes, house_house_id, housestyle_style_id, ceilings)
VALUES (21002, 'Living Room', 400, '1st', 3, 'Spacious family living area', 8006, 4002, '9ft flat');

INSERT INTO rooms (room_id, name, "Size", floor, no_of_windows, notes, house_house_id, housestyle_style_id, ceilings)
VALUES (21003, 'Kitchen', 250, '1st', 2, 'Open kitchen with island', 8006, 4002, '9ft flat');

INSERT INTO rooms (room_id, name, "Size", floor, no_of_windows, notes, house_house_id, housestyle_style_id, ceilings)
VALUES (21004, 'Master Bedroom', 350, '2nd', 4, 'Includes walk-in closet', 8006, 4002, 'Vaulted ceiling');

INSERT INTO rooms (room_id, name, "Size", floor, no_of_windows, notes, house_house_id, housestyle_style_id, ceilings)
VALUES (21005, 'Bathroom', 120, '2nd', 1, 'Master bathroom with tub', 8006, 4002, '9ft flat');

-- =========================================
-- Rooms for House 8007 (Colonial Classic, Lot 2007, Elevation 6007)
-- =========================================
INSERT INTO rooms (room_id, name, "Size", floor, no_of_windows, notes, house_house_id, housestyle_style_id, ceilings)
VALUES (21006, 'Living Room', 420, '1st', 4, 'Living area with fireplace', 8007, 4002, '9ft flat');

INSERT INTO rooms (room_id, name, "Size", floor, no_of_windows, notes, house_house_id, housestyle_style_id, ceilings)
VALUES (21007, 'Kitchen', 260, '1st', 2, 'Kitchen with breakfast nook', 8007, 4002, '9ft flat');

INSERT INTO rooms (room_id, name, "Size", floor, no_of_windows, notes, house_house_id, housestyle_style_id, ceilings)
VALUES (21008, 'Master Bedroom', 360, '2nd', 3, 'Bedroom with balcony access', 8007, 4002, 'Tray ceiling');

INSERT INTO rooms (room_id, name, "Size", floor, no_of_windows, notes, house_house_id, housestyle_style_id, ceilings)
VALUES (21009, 'Bathroom', 130, '2nd', 1, 'Double vanity bathroom', 8007, 4002, '9ft flat');

-- =========================================
-- Option Categories
-- =========================================
INSERT INTO optioncategory (category_id, categoryname)
VALUES (501, 'Kitchen Upgrades');

INSERT INTO optioncategory (category_id, categoryname)
VALUES (502, 'Bathroom Upgrades');

-- =========================================
-- Options for Modern Ranch (4001)
-- =========================================
INSERT INTO "Option" (option_id, option_name, description, optioncategory_category_id, housestyle_style_id)
VALUES (16001, 'Granite Countertops', 'Premium granite kitchen countertops', 501, 4001);

INSERT INTO "Option" (option_id, option_name, description, optioncategory_category_id, housestyle_style_id)
VALUES (16002, 'Tile Backsplash', 'Ceramic tile backsplash in kitchen', 501, 4001);

-- Options for Colonial Classic (4002)
INSERT INTO "Option" (option_id, option_name, description, optioncategory_category_id, housestyle_style_id)
VALUES (16003, 'Jacuzzi Tub', 'Luxury jacuzzi tub upgrade', 502, 4002);

INSERT INTO "Option" (option_id, option_name, description, optioncategory_category_id, housestyle_style_id)
VALUES (16004, 'Double Vanity Sink', 'Dual sinks for master bathroom', 502, 4002);

-- =========================================
-- Option Stage Prices
-- Stage examples: 1 = Foundation, 2 = Framing, 3 = Finishing
-- =========================================
-- Granite Countertops
INSERT INTO option_stage_price (osp_id, cost, revision_date, stage, option_option_id)
VALUES (18001, 5000, DATE '2025-10-01', 3, 16001);

-- Tile Backsplash
INSERT INTO option_stage_price (osp_id, cost, revision_date, stage, option_option_id)
VALUES (18002, 1500, DATE '2025-10-01', 3, 16002);

-- Jacuzzi Tub
INSERT INTO option_stage_price (osp_id, cost, revision_date, stage, option_option_id)
VALUES (18003, 7000, DATE '2025-10-01', 3, 16003);

-- Double Vanity Sink
INSERT INTO option_stage_price (osp_id, cost, revision_date, stage, option_option_id)
VALUES (18004, 2500, DATE '2025-10-01', 3, 16004);

-- =========================================
-- Housetasks (One per house for foundation work)
-- =========================================
INSERT INTO housetask (housetask_id, stage, required, plannedstart, plannedend, notes, 
                       house_house_id, employee_employee_id, plannedcost, actualcost, percent_complete)
VALUES (10001, 1, 'Y', DATE '2025-11-01', DATE '2025-12-01', 'Foundation work', 8006, 26001, 20000, 5000, 0.25);

INSERT INTO housetask (housetask_id, stage, required, plannedstart, plannedend, notes, 
                       house_house_id, employee_employee_id, plannedcost, actualcost, percent_complete)
VALUES (10002, 1, 'Y', DATE '2025-12-01', DATE '2026-01-15', 'Foundation work', 8007, 26002, 21000, 6000, 0.30);

-- =========================================
-- Construction Tasks (Linked to housetasks)
-- =========================================
INSERT INTO construction_task (task_id, description, stage, basecost, approval, housetask_housetask_id)
VALUES (12001, 'Excavation and grading', 1, 8000, 'Y', 10001);

INSERT INTO construction_task (task_id, description, stage, basecost, approval, housetask_housetask_id)
VALUES (12002, 'Concrete foundation pour', 1, 12000, 'N', 10001);

INSERT INTO construction_task (task_id, description, stage, basecost, approval, housetask_housetask_id)
VALUES (12003, 'Excavation and grading', 1, 8500, 'Y', 10002);

INSERT INTO construction_task (task_id, description, stage, basecost, approval, housetask_housetask_id)
VALUES (12004, 'Concrete foundation pour', 1, 12500, 'N', 10002);

-- =========================================
-- Decorator Sessions (one per housetask)
-- =========================================
INSERT INTO decorator_session (decoratorsession_id, "Date", stage, housetask_housetask_id, approval)
VALUES (14001, DATE '2026-02-01', 2, 10001, 'N');

INSERT INTO decorator_session (decoratorsession_id, "Date", stage, housetask_housetask_id, approval)
VALUES (14002, DATE '2026-03-01', 2, 10002, 'Y');

-- =========================================
-- Decorator Choices (selecting Options for these houses)
-- Colonial Classic House 8006 chooses Granite Countertops
-- Colonial Classic House 8007 chooses Jacuzzi Tub
-- =========================================
INSERT INTO decorator_choice (decoratorchoice_id, item, description, price, decorator_session_id, option_option_id)
VALUES (17001, 'Granite Countertops', 'Kitchen upgrade: Black Pearl granite', 5000, 14001, 16001);

INSERT INTO decorator_choice (decoratorchoice_id, item, description, price, decorator_session_id, option_option_id)
VALUES (17002, 'Jacuzzi Tub', 'Bathroom upgrade: Jacuzzi tub', 7000, 14002, 16003);

-- =========================================
-- Task Progress (tracking completion of housetasks)
-- =========================================
INSERT INTO task_progress (progress_id, percentage_complete, estimatedcompletiondate, housetask_housetask_id)
VALUES (18001, 0.25, DATE '2025-12-01', 10001);

INSERT INTO task_progress (progress_id, percentage_complete, estimatedcompletiondate, housetask_housetask_id)
VALUES (18002, 0.30, DATE '2026-01-15', 10002);

-- =========================================
-- Photos (linked to task_progress)
-- =========================================
INSERT INTO photo (photo_id, date_uploaded, url, housetask_housetask_id, task_progress_progress_id)
VALUES (20001, DATE '2025-11-10', 'http://example.com/8006_foundation.jpg', 10001, 18001);

INSERT INTO photo (photo_id, date_uploaded, url, housetask_housetask_id, task_progress_progress_id)
VALUES (20002, DATE '2025-12-15', 'http://example.com/8007_foundation.jpg', 10002, 18002);

COMMIT;
