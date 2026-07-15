select
    refund_id,
    order_id,
    refund_amount,   -- gross (inc VAT), order's native currency
    currency,
    refund_ts,
    reason
from {{ source('raw', 'REFUNDS') }}
