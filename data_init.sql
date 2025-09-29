-- Subdivisions
INSERT INTO subdivision (subdivision_id, name, city, state, zip)
VALUES (101, 'Sunnyvale', 'Pittsburgh', 'PA', '15213');

INSERT INTO subdivision (subdivision_id, name, city, state, zip)
VALUES (202, 'Maple Grove', 'Cleveland', 'OH', '44101');

-- Lots
INSERT INTO lot (lot_id, address, city, state, zip, lotsize, description, lotpremium, subdivision_subdivision_id)
VALUES (1101, '456 Oak Ave', 'Pittsburgh', 'PA', '15213', 5000, 'Corner lot', 15000, 101);

-- Houses
INSERT INTO house (house_id, currentconstructionstage, estimatedcompletion, lot_lot_id, housestyle_style_id, elevation_elevation_id)
VALUES (4101, 1, DATE '2026-01-01', 1101, 3001, 3501);

-- Buyers
INSERT INTO buyer (buyer_id, name, address, city, state, zip, phone, email)
VALUES (9001, 'Carol White', '789 Maple St', 'Pittsburgh', 'PA', '15213', '412-555-5555', 'carol@example.com');

-- Employees
INSERT INTO employee (employee_id, name, title, email, phone, active, hire_date, license_number)
VALUES (9201, 'Bob Johnson', 'Site Manager', 'bob.j@company.com', '412-555-4444', 'Y', SYSDATE, 'LIC123');

-- Escrow Agents
INSERT INTO escrowagent (escrowagent_id, name, address, city, state, zip, phone_number)
VALUES (9301, 'Secure Escrow LLC', '202 Market St', 'Pittsburgh', 'PA', '15213', '412-555-6666');

-- Bank + Workers
INSERT INTO bank (bank_id, name, address, zip, state, phone_number)
VALUES (9350, 'First National Bank', '101 Finance St', '15213', 'PA', '412-555-1111');

INSERT INTO bank_worker (worker_id, name, phone_number, fax_number, bank_bank_id)
VALUES (9401, 'Alice Smith', '412-555-2222', '412-555-3333', 9350);

-- Sales
INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, estimatedcompletion,
                  receivedsubdivision, receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, employee_employee_id,
                  house_house_id, bank_worker_worker_id)
VALUES (9501, SYSDATE, 'Mortgage', 50000, DATE '2026-01-01',
        'Y', 'Y', 'Y', 9001, 9301, 9201, 4101, 9401);
