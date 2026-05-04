-- Dimension: student
-- Conformed dimension. One row per student.
-- Connects to all fact tables via student_id.
{{
    config(
        materialized='incremental',
        unique_key='student_sk',
        incremental_strategy = 'insert_overwrite'
    )
}}


with students as (

    select * from {{ ref('stg_csv_dump__students') }}

),

final as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['student_id']) }}  as student_sk,

        -- natural key
        student_id,

        -- identity
        full_name,
        first_name,
        last_name,
        date_of_birth,
        email,

        -- demographics
        gender,
        nationality,
        ethnicity,
        home_county,
        fee_status,

        -- programme
        programme_name,
        programme_code,
        school,

        -- study status
        entry_year,
        current_year_of_study,
        enrolment_status,
        ucas_points,

        -- derived age band at entry
        case
            when ucas_points >= 144 then 'AAA+'
            when ucas_points >= 112 then 'BBB–AAB'
            when ucas_points >= 96  then 'CCC–BBC'
            else 'Below CCC'
        end                          as entry_tariff_band,

        personal_tutor_id

    from students

)

select * from final
