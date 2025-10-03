-- ===========================================================
-- View: v_house_style_details
-- Purpose:
--   To create a comprehensive view that displays all information required
--   by the "House Styles" form in Figure 1 of the case study.
--   This view creates a combination of every house style for every
--   subdivision, ensuring all possibilities are represented.
-- Tables Involved:
--   - HOUSESTYLE, SUBDIVISION: Cross-joined to create all combinations.
--   - ROOMS:      Details of rooms associated with each house style.
--   - ELEVATION:  The different elevation designs available for each style.
-- ===========================================================
CREATE OR REPLACE VIEW v_house_style_details AS
SELECT
    hs.style_id,
    s.name AS subdivision_name,
    hs.stylename,
    hs.baseprice,
    hs.styledescription,
    hs."Size" AS style_size,
    -- Room Details
    r.name AS room_name,
    r."Size" AS room_size,
    r.floor AS room_floor,
    r.no_of_windows AS room_windows,
    r.ceilings AS room_ceiling,
    r.notes AS room_comments,
    -- Elevation Details
    e.elevationcode,
    e.description AS elevation_description,
    e.additionalcostsketch AS elevation_sketch
FROM
    housestyle hs
CROSS JOIN
    subdivision s
LEFT JOIN
    rooms r ON hs.style_id = r.housestyle_style_id
LEFT JOIN
    elevation e ON hs.style_id = e.housestyle_style_id
/


SET DEFINE OFF;
SET SERVEROUTPUT ON;

-- --- Test Data Setup ---
-- 2) Create a house style ("Renaissance")
INSERT INTO housestyle (style_id, stylename, baseprice, styledescription, "Size")
VALUES (3001, 'Renaissance', 250000, 'A classic two-story family home.', 2200);

-- 3) Add rooms for the "Renaissance" style
INSERT INTO rooms (room_id, name, "Size", floor, no_of_windows, ceilings, notes, housestyle_style_id, house_house_id)
VALUES (101, 'Foyer', 120, '1st', 1, 'Cathedral', 'Grand entrance', 3001, 8005);

INSERT INTO rooms (room_id, name, "Size", floor, no_of_windows, ceilings, notes, housestyle_style_id, house_house_id)
VALUES (102, 'Living Room', 400, '1st', 4, '9 ft', 'Spacious and open', 3001, 8005);

INSERT INTO rooms (room_id, name, "Size", floor, no_of_windows, ceilings, notes, housestyle_style_id, house_house_id)
VALUES (103, 'Master Bedroom', 350, '2nd', 3, 'Vaulted', 'Includes walk-in closet', 3001, 8005);

-- 4) Add elevations for the "Renaissance" style
INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (4001, 'A', 'Standard brick front', 'sketch_A.jpg', 3001);

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (4002, 'B', 'Stone accents and modified roofline', 'sketch_B.jpg', 3001);

INSERT INTO elevation (elevation_id, elevationcode, description, additionalcostsketch, housestyle_style_id)
VALUES (4003, 'C', 'Full brick wrap with arched windows', 'sketch_C.jpg', 3001);

COMMIT;


-- --- Query the View for Verification ---
-- Query all details for the "Renaissance" style.
SELECT DISTINCT *
  FROM v_house_style_details
 WHERE style_id = 3001;


-- --- Cleanup Script (Optional) ---
DELETE FROM elevation WHERE housestyle_style_id IN (3001);
DELETE FROM rooms WHERE housestyle_style_id IN (3001);
DELETE FROM housestyle WHERE style_id IN (3001);
COMMIT;

