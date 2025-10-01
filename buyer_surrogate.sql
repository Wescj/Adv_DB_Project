--Show Buyer before insert
Select * from Buyer;

-- Create sequence for surrogate key
CREATE SEQUENCE buyer_seq
  START WITH 24006
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- Create trigger to auto-populate buyer_id
CREATE OR REPLACE TRIGGER buyer_bir
BEFORE INSERT ON buyer
FOR EACH ROW
WHEN (NEW.buyer_id IS NULL)
BEGIN
  SELECT buyer_seq.NEXTVAL
  INTO   :NEW.buyer_id
  FROM   dual;
END;
/

-- Example insert without providing buyer_id
INSERT INTO buyer (name, address, city, state, zip, phone, email)
VALUES ('Oliver Stone', '123 Market St', 'Pittsburgh', 'PA', '15222', '412-555-7777', 'oliver@example.com');

COMMIT;

--Show after
Select * from Buyer;
