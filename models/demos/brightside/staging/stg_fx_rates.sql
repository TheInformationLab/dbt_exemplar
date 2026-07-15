select
    month,             -- 'YYYY-MM'
    eur_to_gbp_avg
from {{ source('raw', 'FX_RATES') }}
