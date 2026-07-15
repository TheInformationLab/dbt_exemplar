-- Optional regression pin against the totals in output/verified_totals.md.
-- Enable by setting the var, e.g.:
--   dbt test --vars '{pinned_finance_total: 3471417.70, pinned_month: "2026-06"}'
-- or set pinned_finance_total in dbt_project.yml. Null = test passes trivially.

{% set pin = var('pinned_finance_total', none) %}

{% if pin is not none %}

with actual as (
    select round(sum(net_amount_gbp), 2) as total
    from {{ ref('fct_sales') }}
    where order_status = 'COMPLETE'
      and not is_test_account
      and not is_staff_order
      and order_month = '{{ var("pinned_month") }}'
)
select *
from actual
where abs(total - {{ pin }}) > 1.00

{% else %}

select 1 as ok where false   -- pin not set; pass

{% endif %}
