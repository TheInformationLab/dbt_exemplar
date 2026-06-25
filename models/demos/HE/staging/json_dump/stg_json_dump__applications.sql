-- Staging: admissions applications
-- Source: applications.json HE_DEMO.RAW.APPLICATIONS_RAW (VARIANT column)
-- Grain: one row per application
-- Note: prior_qualifications array is flattened into stg_json_dump__application_qualifications

with source as (

    select raw_json, __loaded_at from {{ source('json_dump', 'applications_raw') }}

)

, parsed as (

    select
        -- keys
        raw_json:application_id::varchar as application_id

        -- applicant identity
        , raw_json:applicant:first_name::varchar as first_name
        , raw_json:applicant:last_name::varchar as last_name
        , raw_json:applicant:date_of_birth::date as date_of_birth
        , raw_json:applicant:gender::varchar as gender
        , raw_json:applicant:nationality::varchar as nationality
        , raw_json:applicant:ethnicity::varchar as ethnicity
        , raw_json:applicant:home_county::varchar as home_county
        , raw_json:applicant:contact:email::varchar as email

        -- contact
        , raw_json:applicant:contact:phone::varchar as phone
        , raw_json:programme:programme_name::varchar as programme_name

        -- programme applied for
        , raw_json:programme:programme_code::varchar as programme_code
        , raw_json:programme:school::varchar as school
        , raw_json:programme:entry_year::int as entry_year
        , raw_json:application_source::varchar as application_source

        -- application metadata
        , raw_json:application_date::date as application_date
        , raw_json:ucas_points::int as ucas_points
        , raw_json:interview_completed::boolean as interview_completed

        -- interview
        , raw_json:interview_score::float as interview_score
        , raw_json:outcome::varchar as outcome

        -- outcome
        , raw_json:outcome_date::date as outcome_date
        , raw_json:personal_statement_word_count::int
            as personal_statement_word_count

        -- other
        , raw_json:disability_disclosure::varchar as disability_disclosure
        , raw_json:applicant:first_name::varchar
        || ' ' || raw_json:applicant:last_name::varchar as full_name

        -- derived
        , case
            when
                raw_json:nationality::varchar ilike '%International%'
                then 'International'
            else 'Home'
        end as fee_status

        , coalesce (raw_json:outcome::varchar = 'Offer Accepted'
        , false) as is_converted

        -- audit
        , __loaded_at as _loaded_at

    from source

)

select * from parsed
