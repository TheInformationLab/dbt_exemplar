-- The reconciliation guard (this is the "failing-then-passing test" you
-- screenshot for Demo 3's engineering flash).
-- Per month, Finance revenue computed from the line-grain mart must match an
-- INDEPENDENT order-level calculation straight off RAW, within rounding.
-- A row returned = a failed month = the test fails.

with order_level as (

    select
        to_char(o.order_ts, 'YYYY-MM') as order_month,
        sum(
            (o.gross_amount - coalesce(r.total_refund, 0)) / 1.20
            * case when o.currency = 'EUR' then fx.eur_to_gbp_avg else 1 end
        ) as finance_net
    from {{ source('raw', 'ORDERS') }} o
    left join (
        select order_id, sum(refund_amount) as total_refund
        from {{ source('raw', 'REFUNDS') }}
        group by order_id
    ) r on r.order_id = o.order_id
    left join {{ source('raw', 'FX_RATES') }} fx
        on fx.month = to_char(o.order_ts, 'YYYY-MM')
    join {{ ref('dim_customers') }} c on c.customer_id = o.customer_id
    where o.status = 'COMPLETE'
      and c.customer_type = 'Standard'
    group by 1

),

mart_level as (

    select
        order_month,
        sum(net_amount_gbp) as finance_net
    from {{ ref('fct_sales') }}
    where order_status = 'COMPLETE'
      and not is_test_account
      and not is_staff_order
    group by 1

)

select
    o.order_month,
    o.finance_net as order_level_net,
    m.finance_net as mart_level_net,
    abs(o.finance_net - m.finance_net) as abs_diff
from order_level o
join mart_level m using (order_month)
where abs(o.finance_net - m.finance_net) > 1.00   -- tolerance: line-allocation rounding
