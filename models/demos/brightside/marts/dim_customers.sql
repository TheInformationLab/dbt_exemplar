{{ config(grants = {'+select': ['GOVERNED_DEMO_ROLE']}) }}
select
    customer_id,
    first_name || ' ' || last_name as customer_name,
    email,
    country,
    region,
    case
        when email ilike '%@brightside-test.co%' then 'Test account'
        when is_staff                            then 'Staff'
        else 'Standard'
    end                            as customer_type,
    signup_date
from {{ ref('stg_customers') }}
