select
    order_id,
    customer_id,
    order_ts,
    order_ts::date                as order_date,
    to_char(order_ts, 'YYYY-MM')  as order_month,
    status                        as order_status,
    gross_amount,                 -- includes VAT, native currency
    discount_amount,              -- already deducted from gross_amount
    currency,
    channel
from {{ source('raw', 'ORDERS') }}
