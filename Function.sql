-- ===========================================================
-- Function: fn_house_total_price
-- Purpose:
--   Total price for a given house:
--     base housestyle price
--   + lot premium
--   + sum of all decorator choices (already auto-priced)
--
-- Param:
--   p_house_id - HOUSE.HOUSE_ID
--
-- Returns:
--   NUMBER - total price, or NULL if the house doesn't exist
-- ===========================================================
CREATE OR REPLACE FUNCTION fn_house_total_price(
  p_house_id IN house.house_id%TYPE
) RETURN NUMBER IS
  v_total NUMBER := 0;   -- base + lot
  v_opts  NUMBER := 0;   -- sum of decorator choices
BEGIN
  -- Base style price + lot premium
  SELECT hs.baseprice + l.lotpremium
    INTO v_total
    FROM house h
    JOIN housestyle hs ON h.housestyle_style_id = hs.style_id
    JOIN lot l         ON h.lot_lot_id = l.lot_id
   WHERE h.house_id = p_house_id;

  -- Sum of all decorator choices tied to this house (via session -> housetask)
  SELECT SUM(dc.price)
    INTO v_opts
    FROM decorator_choice dc
    JOIN decorator_session ds ON dc.decorator_session_id = ds.decoratorsession_id
    JOIN housetask       ht   ON ds.housetask_housetask_id = ht.housetask_id
   WHERE ht.house_house_id = p_house_id;

  v_total := v_total + NVL(v_opts, 0);

  RETURN v_total;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- house not found: return NULL so callers can detect missing house
    RETURN NULL;
END fn_house_total_price;
/



SELECT fn_house_total_price(6001) AS total_price
FROM dual;