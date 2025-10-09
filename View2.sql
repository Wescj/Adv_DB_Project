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
