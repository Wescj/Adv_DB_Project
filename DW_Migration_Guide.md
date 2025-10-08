# Data Warehouse Migration Guide: Eggshell Home Builder

## 1. Objective

The primary goal is to transform the operational data from the Eggshell OLTP database into a dimensional model (a star schema) optimized for analytics. This will enable the business to answer high-level questions that are difficult or slow to answer with the transactional system, such as:

*   What are our sales trends month-over-month or year-over-year?
*   Which house styles or optional features are most profitable?
*   Which sales employees are the top performers by revenue?
*   What is the average time from sale to construction completion by subdivision?

## 2. Target Schema Design (Star Schema)

We will design a classic star schema with one central **Fact Table** (`FACT_SALES`) surrounded by descriptive **Dimension Tables**.

*   **Fact Table:** Contains numeric *measures* of a business event (e.g., price, quantity).
*   **Dimension Tables:** Contain the "who, what, where, when" context for the facts.

Here is the proposed schema DDL:

### Dimension Tables

```sql
-- Dimension for Time (pre-populated by a script or generator)
CREATE TABLE DIM_DATE (
    DATE_KEY          NUMBER(8) PRIMARY KEY, -- YYYYMMDD
    FULL_DATE         DATE NOT NULL,
    CALENDAR_YEAR     NUMBER(4),
    CALENDAR_QUARTER  VARCHAR2(2), -- 'Q1', 'Q2', etc.
    CALENDAR_MONTH    NUMBER(2),
    MONTH_NAME        VARCHAR2(20)
);

-- Dimension for House, Lot, and Subdivision details
CREATE TABLE DIM_HOUSE (
    HOUSE_KEY         NUMBER PRIMARY KEY,
    HOUSE_ID          NUMBER, -- Natural key from OLTP
    HOUSE_STYLE       VARCHAR2(100),
    ELEVATION_NAME    VARCHAR2(100),
    LOT_NUMBER        VARCHAR2(20),
    SUBDIVISION_NAME  VARCHAR2(100),
    BASE_PRICE        NUMBER(12, 2)
);

-- Dimension for Buyer details
CREATE TABLE DIM_BUYER (
    BUYER_KEY         NUMBER PRIMARY KEY,
    BUYER_ID          NUMBER, -- Natural key from OLTP
    BUYER_NAME        VARCHAR2(200),
    BUYER_CITY        VARCHAR2(100),
    BUYER_STATE       VARCHAR2(2)
);

-- Dimension for Employee details
CREATE TABLE DIM_EMPLOYEE (
    EMPLOYEE_KEY      NUMBER PRIMARY KEY,
    EMPLOYEE_ID       NUMBER, -- Natural key from OLTP
    EMPLOYEE_NAME     VARCHAR2(200),
    JOB_TITLE         VARCHAR2(100)
);
```

### Fact Table

```sql
-- Central Fact Table for Sales
CREATE TABLE FACT_SALES (
    SALE_ID               NUMBER PRIMARY KEY, -- Natural key from OLTP
    -- Foreign Keys to Dimensions
    DATE_KEY              NUMBER(8) REFERENCES DIM_DATE(DATE_KEY),
    HOUSE_KEY             NUMBER REFERENCES DIM_HOUSE(HOUSE_KEY),
    BUYER_KEY             NUMBER REFERENCES DIM_BUYER(BUYER_KEY),
    EMPLOYEE_KEY          NUMBER REFERENCES DIM_EMPLOYEE(EMPLOYEE_KEY),
    -- Numeric Measures
    TOTAL_CONTRACT_PRICE  NUMBER(12, 2),
    ESCROW_DEPOSIT        NUMBER(12, 2),
    OPTION_UPGRADE_COST   NUMBER(12, 2), -- Calculated during ETL
    BASE_PRICE_AT_SALE    NUMBER(12, 2)  -- Snapshot of base price
);
```

## 3. ETL (Extract, Transform, Load) Process

The ETL process will be a series of SQL statements that populate our new DW tables from the existing OLTP tables. This process would typically be automated to run nightly.

### Step 3.1: Create Sequences for DW Surrogate Keys

Surrogate keys (like `HOUSE_KEY`, `BUYER_KEY`) are warehouse-specific keys that are independent of the operational system's keys.

```sql
CREATE SEQUENCE dim_house_seq START WITH 1;
CREATE SEQUENCE dim_buyer_seq START WITH 1;
CREATE SEQUENCE dim_employee_seq START WITH 1;
```

### Step 3.2: Populate Dimension Tables

We extract data from multiple OLTP tables, join them, and load the denormalized results into our dimensions.

**`DIM_HOUSE` Population:**
```sql
-- Extract and transform house, style, lot, and subdivision data
INSERT INTO DIM_HOUSE (HOUSE_KEY, HOUSE_ID, HOUSE_STYLE, ELEVATION_NAME, LOT_NUMBER, SUBDIVISION_NAME, BASE_PRICE)
SELECT
    dim_house_seq.NEXTVAL,
    h.house_id,
    hs.stylename,
    e.elevationname,
    l.lotnumber,
    sd.name,
    hs.baseprice
FROM house h
JOIN housestyle hs ON h.housestyle_style_id = hs.style_id
JOIN elevation e ON h.elevation_elevation_id = e.elevation_id
JOIN lot l ON h.lot_lot_id = l.lot_id
JOIN subdivision sd ON l.subdivision_subdivision_id = sd.subdivision_id;
```

**`DIM_BUYER` Population:**
```sql
-- Extract and transform buyer data
INSERT INTO DIM_BUYER (BUYER_KEY, BUYER_ID, BUYER_NAME, BUYER_CITY, BUYER_STATE)
SELECT
    dim_buyer_seq.NEXTVAL,
    buyer_id,
    name, -- Assuming 'name' column exists
    city,
    state
FROM buyer;
```

**`DIM_EMPLOYEE` Population:**
```sql
-- Extract and transform employee data
INSERT INTO DIM_EMPLOYEE (EMPLOYEE_KEY, EMPLOYEE_ID, EMPLOYEE_NAME, JOB_TITLE)
SELECT
    dim_employee_seq.NEXTVAL,
    employee_id,
    name, -- Assuming 'name' column exists
    title
FROM employee;
```

### Step 3.3: Populate the Fact Table

This is the final and most important step. We join the OLTP `SALE` table with our newly created dimension tables to look up the surrogate keys.

```sql
-- Extract sales facts and link to dimensions
INSERT INTO FACT_SALES (
    SALE_ID, DATE_KEY, HOUSE_KEY, BUYER_KEY, EMPLOYEE_KEY,
    TOTAL_CONTRACT_PRICE, ESCROW_DEPOSIT, OPTION_UPGRADE_COST, BASE_PRICE_AT_SALE
)
SELECT
    s.sale_id,
    TO_NUMBER(TO_CHAR(s."Date", 'YYYYMMDD')) AS DATE_KEY, -- Match DIM_DATE key format
    dh.HOUSE_KEY,
    db.BUYER_KEY,
    de.EMPLOYEE_KEY,
    s.total_contract_price,
    s.escrowdeposit,
    -- Transformation: Calculate the cost of options on the fly
    (s.total_contract_price - dh.BASE_PRICE) AS OPTION_UPGRADE_COST,
    dh.BASE_PRICE AS BASE_PRICE_AT_SALE
FROM
    sale s
-- Join to Dimension tables to get the surrogate keys
JOIN DIM_HOUSE dh    ON s.house_house_id = dh.HOUSE_ID
JOIN DIM_BUYER db    ON s.buyer_buyer_id = db.BUYER_ID
JOIN DIM_EMPLOYEE de ON s.employee_employee_id = de.EMPLOYEE_ID;
```

## 4. Sample Analytical Queries

Once the data warehouse is populated, you can run powerful, high-performance analytical queries.

**Query 1: Total Sales Revenue by Quarter**
```sql
SELECT
    d.CALENDAR_YEAR,
    d.CALENDAR_QUARTER,
    SUM(f.TOTAL_CONTRACT_PRICE) AS total_revenue
FROM FACT_SALES f
JOIN DIM_DATE d ON f.DATE_KEY = d.DATE_KEY
GROUP BY d.CALENDAR_YEAR, d.CALENDAR_QUARTER
ORDER BY d.CALENDAR_YEAR, d.CALENDAR_QUARTER;
```

**Query 2: Top 3 House Styles by Total Option Upgrade Revenue**
```sql
SELECT * FROM (
    SELECT
        h.HOUSE_STYLE,
        SUM(f.OPTION_UPGRADE_COST) AS total_option_revenue
    FROM FACT_SALES f
    JOIN DIM_HOUSE h ON f.HOUSE_KEY = h.HOUSE_KEY
    GROUP BY h.HOUSE_STYLE
    ORDER BY total_option_revenue DESC
)
WHERE ROWNUM <= 3;
```