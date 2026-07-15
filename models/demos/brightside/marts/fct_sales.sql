{#-
    Grain: one row per order LINE.
    The order-level GROSS_AMOUNT is the financial source of truth, so line
    amounts are scaled to sum exactly to it (absorbing the ~2% legacy
    order-vs-items warts). Refunds are allocated to lines proportionally
    and attributed to the ORDER's month. Flat 20% VAT (documented
    simplification); EUR converted at the order month's average rate.
-#}
{{ config(grants = {'+select': ['GOVERNED_DEMO_ROLE']}) }}

with order_refunds as (

    select
        order_id,
        sum(refund_amount) as total_refund
    from {{ ref('stg_refunds') }}
    group by order_id

),

line_share as (

    select
        order_item_id,
        order_id,
        product_id,
        quantity,
        line_gross_amount
            / nullif(sum(line_gross_amount) over (partition by order_id), 0)
            as share_of_order
    from {{ ref('stg_order_items') }}

)

select
    ls.order_item_id                                   as sale_line_id,
    o.order_id,
    o.customer_id,
    ls.product_id,
    ls.quantity,
    o.order_ts,
    o.order_date,
    o.order_month,
    o.order_status,
    o.channel,
    o.currency,
    c.customer_type,
    (c.customer_type = 'Test account')                 as is_test_account,
    (c.customer_type = 'Staff')                        as is_staff_order,

    -- allocated amounts (order gross is the source of truth):
    round(o.gross_amount * ls.share_of_order, 4)       as gross_amount_native,
    round(coalesce(r.total_refund, 0) * ls.share_of_order, 4)
                                                       as refund_amount_native,

    -- Finance's net: (gross - refunds), VAT removed, EUR converted:
    round(
        (o.gross_amount - coalesce(r.total_refund, 0)) * ls.share_of_order
        / 1.20
        * case when o.currency = 'EUR' then fx.eur_to_gbp_avg else 1 end
    , 4)                                               as net_amount_gbp

from line_share ls
join {{ ref('stg_orders') }} o        on o.order_id = ls.order_id
join {{ ref('dim_customers') }} c     on c.customer_id = o.customer_id
left join order_refunds r             on r.order_id = o.order_id
left join {{ ref('stg_fx_rates') }} fx on fx.month = o.order_month
