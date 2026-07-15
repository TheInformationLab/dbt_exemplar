{{ config(materialized='table') }}

-- Day-grain time spine required by MetricFlow for metric_time queries.
-- Covers the demo window with headroom.
select
    dateadd(day, row_number() over (order by null) - 1, '2024-01-01'::date)
        as date_day
from table(generator(rowcount => 1500))
qualify date_day <= dateadd(day, 30, current_date)
