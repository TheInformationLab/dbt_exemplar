-- Staging: fee charges
-- Source: fee_charges.csv → HE_DEMO.RAW.FEE_CHARGES
-- Grain: one row per charge event

with source as (

    select * from {{ source('csv_dump', 'fee_charges') }}

),

renamed as (

    select
        -- keys
        fee_id,
        student_id,

        -- term
        academic_term,
        split_part(academic_term, '/', 1)::int as academic_year_start,

        -- fee attributes
        fee_type,
        fee_category,
        charge_date::date                as charge_date,
        currency,

        -- financials
        amount_charged::float            as amount_charged,
        amount_paid::float               as amount_paid,
        outstanding_balance::float       as outstanding_balance,
        payment_plan,
        waiver_applied::boolean          as waiver_applied,

        -- derived
        case
            when outstanding_balance = 0 then 'Fully Paid'
            when outstanding_balance > 0
             and outstanding_balance < amount_charged then 'Partially Paid'
            else 'Unpaid'
        end                              as payment_status,

        -- audit
        current_timestamp()              as _loaded_at

    from source

)

select * from renamed
