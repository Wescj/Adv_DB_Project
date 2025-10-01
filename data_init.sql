-- =========================================
-- Subdivisions (2)
-- =========================================
INSERT INTO subdivision (subdivision_id, name, city, state, zip)
VALUES (1, 'Sunnyvale', 'Pittsburgh', 'PA', '15213');

INSERT INTO subdivision (subdivision_id, name, city, state, zip)
VALUES (2, 'Maple Grove', 'Cleveland', 'OH', '44101');

-- =========================================
-- Buyers (5) [Range: 9001–9005]
-- =========================================
INSERT INTO buyer (buyer_id, name, address, city, state, zip, phone, email)
VALUES (9001, 'Carol White', '789 Maple St', 'Pittsburgh', 'PA', '15213', '412-555-5555', 'carol@example.com');

INSERT INTO buyer (buyer_id, name, address, city, state, zip, phone, email)
VALUES (9002, 'Frank Green', '999 Oak Blvd', 'Cleveland', 'OH', '44101', '216-555-6666', 'frank@example.com');

INSERT INTO buyer (buyer_id, name, address, city, state, zip, phone, email)
VALUES (9003, 'Helen Black', '23 River Ln', 'Pittsburgh', 'PA', '15214', '412-555-1111', 'helen@example.com');

INSERT INTO buyer (buyer_id, name, address, city, state, zip, phone, email)
VALUES (9004, 'Michael Gray', '7 Lake Ave', 'Cleveland', 'OH', '44102', '216-555-2222', 'michael@example.com');

INSERT INTO buyer (buyer_id, name, address, city, state, zip, phone, email)
VALUES (9005, 'Nina Brown', '14 Oak St', 'Pittsburgh', 'PA', '15215', '412-555-3333', 'nina@example.com');

-- =========================================
-- Employees (3) [Range: 9201–9203]
-- =========================================
INSERT INTO employee (employee_id, name, title, email, phone, active, hire_date, license_number)
VALUES (9201, 'Bob Johnson', 'Site Manager', 'bob.j@company.com', '412-555-4444', 'Y', SYSDATE, 'LIC123');

INSERT INTO employee (employee_id, name, title, email, phone, active, hire_date, license_number)
VALUES (9202, 'Eva Martinez', 'Engineer', 'eva.m@company.com', '216-555-7777', 'Y', SYSDATE, 'LIC456');

INSERT INTO employee (employee_id, name, title, email, phone, active, hire_date, license_number)
VALUES (9203, 'Liam Chen', 'Architect', 'liam.c@company.com', '614-555-9999', 'Y', SYSDATE, 'LIC789');

-- =========================================
-- Escrow Agents (2)
-- =========================================
INSERT INTO escrowagent (escrowagent_id, name, address, city, state, zip, phone_number)
VALUES (1001, 'Secure Escrow LLC', '202 Market St', 'Pittsburgh', 'PA', '15213', '412-555-6666');

INSERT INTO escrowagent (escrowagent_id, name, address, city, state, zip, phone_number)
VALUES (1002, 'Ohio Escrow Inc', '88 River Rd', 'Cleveland', 'OH', '44101', '216-555-1234');

-- =========================================
-- Bank & Workers (1 bank, 2 workers)
-- =========================================
INSERT INTO bank (bank_id, name, address, zip, state, phone_number)
VALUES (700, 'First National Bank', '101 Finance St', '15213', 'PA', '412-555-1111');

INSERT INTO bank_worker (worker_id, name, phone_number, fax_number, bank_bank_id)
VALUES (701, 'Alice Smith', '412-555-2222', '412-555-3333', 700);

INSERT INTO bank_worker (worker_id, name, phone_number, fax_number, bank_bank_id)
VALUES (702, 'David Brown', '216-555-8888', '216-555-9999', 700);

-- =========================================
-- HouseStyle (1) & Elevations (5 distinct)
-- =========================================
INSERT INTO housestyle (style_id, stylename, baseprice, styledescription, "Size", photo, numberwindows, ceiling)
VALUES (4001, 'Modern Ranch', 250000, 'Open layout', 2000, EMPTY_BLOB(), 10, 'Vaulted');

-- Create 5 distinct elevations so each house can reference a unique elevation_id
INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (6001, 'E1', 'Basic elevation', 'None', 4001);

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (4002, 'E2', 'Stone accents', 'Stone front option', 3001);

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (4003, 'E3', 'Board and batten', 'Vertical siding sketch', 3001);

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (4004, 'E4', 'Dormer windows', 'Dormer add-on', 3001);

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (4005, 'E5', 'Porch wrap', 'Porch wraparound', 3001);

-- =========================================
-- Lots (5)  *** FIXED subdivision IDs ***
-- =========================================
INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (501, '456 Oak Ave', 'Pittsburgh', 'PA', '15213', 5000, 'Corner lot', 15000, 1);

INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (502, '22 Maple Rd', 'Cleveland', 'OH', '44101', 6000, 'Near park', 12000, 2);

INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (503, '99 River St', 'Pittsburgh', 'PA', '15214', 4800, 'Near river', 10000, 1);

INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (504, '11 Lake Dr', 'Cleveland', 'OH', '44102', 5500, 'Lake view', 20000, 2);

INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (505, '5 Hilltop Ct', 'Pittsburgh', 'PA', '15216', 5200, 'On hilltop', 17000, 1);

-- =========================================
-- Houses (5)  *** each uses a unique elevation_id ***
-- =========================================
INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (8001, 1, DATE '2026-01-01', 2001, 4001, 6001);

INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (6002, 2, DATE '2026-03-15', 502, 3001, 4002);

INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (6003, 1, DATE '2026-05-20', 503, 3001, 4003);

INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (6004, 3, DATE '2026-07-10', 504, 3001, 4004);

INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (6005, 2, DATE '2026-09-01', 505, 3001, 4005);

-- =========================================
-- Sales (5, one per house)  *** FIXED buyer & employee IDs ***
-- =========================================
INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, estimatedcompletion,
                  receivedsubdivision, receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, employee_employee_id,
                  house_house_id, bank_worker_worker_id)
VALUES (2001, SYSDATE, 'Mortgage', 50000, DATE '2026-01-01',
        'Y', 'Y', 'Y', 9001, 1001, 9201, 6001, 701);

INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, estimatedcompletion,
                  receivedsubdivision, receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, employee_employee_id,
                  house_house_id, bank_worker_worker_id)
VALUES (2002, SYSDATE, 'Cash', 100000, DATE '2026-03-15',
        'Y', 'N', 'Y', 9002, 1002, 9202, 6002, 702);

INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, estimatedcompletion,
                  receivedsubdivision, receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, employee_employee_id,
                  house_house_id, bank_worker_worker_id)
VALUES (2003, SYSDATE, 'Mortgage', 75000, DATE '2026-05-20',
        'N', 'Y', 'Y', 9003, 1001, 9203, 6003, 701);

INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, estimatedcompletion,
                  receivedsubdivision, receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, employee_employee_id,
                  house_house_id, bank_worker_worker_id)
VALUES (2004, SYSDATE, 'Cash', 120000, DATE '2026-07-10',
        'Y', 'Y', 'N', 9004, 1002, 9202, 6004, 702);

INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, estimatedcompletion,
                  receivedsubdivision, receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, employee_employee_id,
                  house_house_id, bank_worker_worker_id)
VALUES (2005, SYSDATE, 'Mortgage', 90000, DATE '2026-09-01',
        'Y', 'N', 'Y', 9005, 1001, 9201, 6005, 701);

COMMIT;
