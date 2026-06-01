-- Staging: students
-- Source: students.csv → HE_DEMO.RAW.STUDENTS
-- Grain: one row per student

with source as (

    select * from {{ source('csv_dump', 'students') }}

)

, renamed as (

    select
        -- keys
        student_id
        , personal_tutor_id

        -- identity
        , first_name
        , last_name
        , to_date(date_of_birth, 'DD/MM/YYYY')::date as date_of_birth
        , email
        , gender

        -- demographics
        , nationality
        , ethnicity
        , home_county
        , programme_name

        -- programme
        , programme_code
        , school
        , entry_year::int as entry_year

        -- study
        , current_year_of_study::int as current_year_of_study
        , enrolment_status
        , ucas_points::int as ucas_points
        , first_name || ' ' || last_name as full_name

        -- meta
        , case
            when nationality ilike '%International%' then 'International'
            else 'Home'
        end as fee_status

        -- audit
        , current_timestamp() as _loaded_at

    from source

)

select * from renamed
