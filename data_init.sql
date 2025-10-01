-- =========================================
-- Subdivisions (2)
-- =========================================
INSERT INTO subdivision (subdivision_id, name, city, state, zip)
VALUES (1, 'Sunnyvale', 'Pittsburgh', 'PA', '15213');

INSERT INTO subdivision (subdivision_id, name, city, state, zip)
VALUES (2, 'Maple Grove', 'Cleveland', 'OH', '44101');

-- =========================================
-- HouseStyle (1) & Elevations (5 distinct)
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

COMMIT;
