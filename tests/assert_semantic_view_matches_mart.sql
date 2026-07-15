-- The semantic layer eval: on every build, ask the semantic view for monthly
-- net revenue and compare it with the same calculation straight off the mart.
-- If someone edits a metric definition and breaks it, CI fails before any
-- agent or dashboard ever sees the wrong number.
-- A row returned = a divergent month = the test fails.

with from_semantic_view as (

    select *
    from semantic_view(
        {{ ref('brightside_sales') }}
        metrics sales.net_revenue
        dimensions sales.order_month
    )

),

from_mart as (

    select
        order_month,
        sum(case when order_status = 'COMPLETE'
                  and not is_test_account
                  and not is_staff_order
                 then net_amount_gbp else 0 end) as net_revenue
    from {{ ref('fct_sales') }}
    group by 1

)

select
    m.order_month,
    sv.net_revenue as semantic_view_answer,
    m.net_revenue  as mart_answer,
    abs(sv.net_revenue - m.net_revenue) as abs_diff
from from_mart m
join from_semantic_view sv using (order_month)
where abs(sv.net_revenue - m.net_revenue) > 0.01
