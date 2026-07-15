select
    customer_id,
    first_name,
    last_name,
    email,
    country,
    region,
    is_staff,
    signup_date
from {{ source('raw', 'CUSTOMERS') }}
