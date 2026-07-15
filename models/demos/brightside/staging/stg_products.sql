select
    product_id,
    product_name,
    category,
    unit_price_ex_vat
from {{ source('raw', 'PRODUCTS') }}
