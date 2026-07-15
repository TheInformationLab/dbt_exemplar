{{
    config(
        materialized = 'semantic_view',
        post_hook = "GRANT SELECT ON SEMANTIC VIEW {{ this }} TO ROLE GOVERNED_DEMO_ROLE"
    )
}}

/*
    The semantic layer as a first-class dbt model (Snowflake-Labs
    dbt_semantic_view package). It appears in the DAG downstream of the marts,
    is deployed by `dbt build`, and can be queried by dbt tests -- see
    tests/assert_semantic_view_matches_mart.sql, which regression-tests the
    semantic view's own answer against the mart on every build.

    The model NAME becomes the object name: ANALYTICS.BRIGHTSIDE_SALES.
*/

TABLES (
    sales AS {{ ref('fct_sales') }}
        PRIMARY KEY (SALE_LINE_ID)
        WITH SYNONYMS ('sales', 'orders', 'transactions')
        COMMENT = 'One row per order line. Amounts allocated from order-level totals (financial source of truth). Refunds attributed to the order month.',
    customers AS {{ ref('dim_customers') }}
        PRIMARY KEY (CUSTOMER_ID)
        WITH SYNONYMS ('clients', 'accounts', 'shoppers')
        COMMENT = 'Customer master. CUSTOMER_TYPE distinguishes Standard, Staff, and Test accounts.',
    products AS {{ ref('dim_products') }}
        PRIMARY KEY (PRODUCT_ID)
        WITH SYNONYMS ('items', 'SKUs', 'catalogue')
        COMMENT = 'Product catalogue, 6 categories.'
)

RELATIONSHIPS (
    sales_to_customers AS sales (CUSTOMER_ID) REFERENCES customers,
    sales_to_products  AS sales (PRODUCT_ID)  REFERENCES products
)

FACTS (
    sales.net_amount_gbp AS NET_AMOUNT_GBP
        COMMENT = 'Line amount net of VAT and refunds, converted to GBP at the order month average rate. All statuses and account types included -- filter before summing.',
    sales.gross_amount_native AS GROSS_AMOUNT_NATIVE
        COMMENT = 'Line gross including VAT, in native currency (GBP or EUR). NOT safe to sum across currencies.',
    sales.refund_amount_native AS REFUND_AMOUNT_NATIVE
        COMMENT = 'Refunds allocated to this line, gross, native currency.',
    sales.revenue_amount_gbp AS
        CASE WHEN sales.ORDER_STATUS = 'COMPLETE'
              AND NOT sales.IS_TEST_ACCOUNT
              AND NOT sales.IS_STAFF_ORDER
             THEN sales.NET_AMOUNT_GBP ELSE 0 END
        COMMENT = 'The Finance definition of recognisable revenue at line level: COMPLETE orders only, excluding staff and test accounts, net of VAT and refunds, GBP.',
    sales.is_finance_revenue LABELS = (FILTER) AS
        (sales.ORDER_STATUS = 'COMPLETE'
         AND NOT sales.IS_TEST_ACCOUNT
         AND NOT sales.IS_STAFF_ORDER)
        COMMENT = 'TRUE where the line counts toward Finance revenue.'
)

DIMENSIONS (
    sales.order_date AS ORDER_DATE
        WITH SYNONYMS ('date', 'purchase date', 'transaction date')
        COMMENT = 'Calendar date the order was placed.',
    sales.order_month AS ORDER_MONTH
        WITH SYNONYMS ('month')
        COMMENT = 'Order month, YYYY-MM.',
    sales.order_status AS ORDER_STATUS
        WITH SYNONYMS ('status', 'order state')
        COMMENT = 'COMPLETE, CANCELLED, RETURNED, or PENDING. Only COMPLETE counts toward revenue.',
    sales.channel AS CHANNEL
        WITH SYNONYMS ('sales channel', 'platform')
        COMMENT = 'WEB, APP, or MARKETPLACE.',
    sales.currency AS CURRENCY
        COMMENT = 'Native order currency: GBP, or EUR (Irish pilot).',
    customers.region AS REGION
        WITH SYNONYMS ('area', 'geography')
        COMMENT = 'UK region, or Ireland.',
    customers.customer_type AS CUSTOMER_TYPE
        WITH SYNONYMS ('account type')
        COMMENT = 'Standard, Staff, or Test account. Staff and Test are excluded from revenue.',
    products.category AS CATEGORY
        WITH SYNONYMS ('product category', 'department', 'range')
        COMMENT = 'One of six product categories.',
    products.product_name AS PRODUCT_NAME
        WITH SYNONYMS ('item name', 'product')
        COMMENT = 'Product display name.'
)

METRICS (
    sales.net_revenue AS SUM(sales.revenue_amount_gbp)
        WITH SYNONYMS ('revenue', 'sales', 'turnover', 'takings', 'income')
        COMMENT = 'OFFICIAL revenue (Finance definition): net of VAT and refunds, COMPLETE orders only, staff and test accounts excluded, GBP (EUR converted at monthly average rate). Refunds attributed to the order month. Use this for any revenue question unless gross is explicitly requested.',
    sales.refunds_gbp AS
        SUM(sales.REFUND_AMOUNT_NATIVE / 1.20
            * CASE WHEN sales.CURRENCY = 'EUR' THEN 0.86 ELSE 1 END)
        WITH SYNONYMS ('refund total', 'money returned')
        COMMENT = 'Approximate refunds net of VAT in GBP (EUR at 0.86 flat -- indicative only).',
    sales.order_count AS COUNT(DISTINCT sales.ORDER_ID)
        WITH SYNONYMS ('number of orders', 'order volume')
        COMMENT = 'Distinct orders (any status).',
    sales.units_sold AS SUM(sales.QUANTITY)
        WITH SYNONYMS ('quantity', 'items sold')
        COMMENT = 'Total units across lines (any status).',
    avg_order_value AS sales.net_revenue / NULLIF(sales.order_count, 0)
        WITH SYNONYMS ('AOV', 'basket value')
        COMMENT = 'Derived: net revenue divided by distinct order count. Note the denominator includes non-revenue orders; refine if challenged.'
)

COMMENT = 'Brightside Retail sales semantic model. Single source of truth for revenue definitions, consumed by Cortex Analyst / CoWork, MCP clients, and BI. Managed as a dbt model via the dbt_semantic_view package.'

AI_SQL_GENERATION
    'When the user asks about revenue, sales, turnover or takings, always use the net_revenue metric unless they explicitly ask for gross amounts. Never sum gross_amount_native across currencies. "Last month" means the most recent complete calendar month. If a question cannot be answered from this model (e.g. web traffic, inventory, marketing spend), say so plainly and suggest the user contact the data team; do not attempt an approximate answer.'

AI_VERIFIED_QUERIES (
    monthly_net_revenue AS (
        QUESTION 'What was our revenue last month?'
        VERIFIED_AT 1783555200
        ONBOARDING_QUESTION TRUE
        SQL 'SELECT * FROM SEMANTIC_VIEW(BRIGHTSIDE.ANALYTICS.BRIGHTSIDE_SALES METRICS sales.net_revenue DIMENSIONS sales.order_month WHERE sales.order_month = ''2026-06'')'
    ),
    march_dip_by_category AS (
        QUESTION 'Which product category drove the revenue dip in March, excluding the warehouse relocation week?'
        VERIFIED_AT 1783555200
        SQL 'SELECT * FROM SEMANTIC_VIEW(BRIGHTSIDE.ANALYTICS.BRIGHTSIDE_SALES METRICS sales.net_revenue DIMENSIONS products.category, sales.order_month WHERE sales.order_month IN (''2026-02'', ''2026-03'', ''2026-04'') AND NOT (sales.order_date BETWEEN ''2026-03-09'' AND ''2026-03-15'')) ORDER BY category, order_month'
    )
)
