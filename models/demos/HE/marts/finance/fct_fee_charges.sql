-- Fact: student fee charges
-- Grain: one row per fee charge event
-- Kimball type: transaction fact
-- Domain: finance mart
{{
    config(
        materialized='incremental',
        unique_key='fee_sk',
        incremental_strategy = 'merge'
    )
}}


with fees as (

    select * from {{ ref('stg_csv_dump__fee_charges') }}

)

, dim_student as (

    select
        student_sk
        , student_id
    from {{ ref('dim_student') }}

)

, dim_term as (

    select
        term_sk
        , academic_term
    from {{ ref('dim_term') }}

)

, final as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['f.fee_id']) }} as fee_sk

        -- natural key
        , f.fee_id

        -- foreign keys
        , d_stu.student_sk
        , d_trm.term_sk

        -- degenerate dimensions
        , f.fee_type
        , f.fee_category
        , f.payment_plan
        , f.payment_status
        , f.currency

        -- dates
        , f.charge_date

        -- additive financial measures (all in GBP)
        , f.amount_charged
        , f.amount_paid
        , f.outstanding_balance

        -- flags
        , f.waiver_applied
        , case when f.waiver_applied then 1 else 0 end as waiver_flag
        , case when f.payment_status = 'Unpaid' then 1 else 0 end as unpaid_flag
        , 1 as charge_count
        , greatest(f._loaded_at, d_stu._loaded_at, d_trm._loaded_at) as _loaded_at

    from fees as f
    inner join dim_student as d_stu on f.student_id = d_stu.student_id
    inner join dim_term as d_trm on f.academic_term = d_trm.academic_term

)

select * from final
{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    where _loaded_at > (select max(_loaded_at) from {{ this }}) 
{% endif %}
