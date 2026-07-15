select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price_gross,
    line_gross_amount
from {{ source('raw', 'ORDER_ITEMS') }}
