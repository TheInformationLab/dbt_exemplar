-- Staging: application prior qualifications (LATERAL FLATTEN)
-- Source: applications.json → HE_DEMO.RAW.APPLICATIONS_RAW
-- Grain: one row per application × qualification
-- Demo highlight: Snowflake VARIANT + LATERAL FLATTEN of nested array

with source as (

    select raw_json from {{ source('json_dump', 'applications_raw') }}

)

, flattened as (

    select
        {{ dbt_utils.generate_surrogate_key([
            'src.raw_json:application_id::varchar'
            ,'qual.index::int'
        ]) }} as application_seq_sk
        , src.raw_json:application_id::varchar as application_id
        , qual.index::int as qualification_seq
        , qual.value:qualification::varchar as qualification_type
        , qual.value:subject::varchar as subject
        , qual.value:grade::varchar as grade

        -- map A-Level grades to UCAS tariff points
        , case qual.value:grade::varchar
            when 'A*' then 56
            when 'A' then 48
            when 'B' then 40
            when 'C' then 32
            when 'D' then 24
            when 'E' then 16
            else 0
        end as ucas_points

        , current_timestamp() as _loaded_at

    from source as src
    , lateral flatten(
        input => src.raw_json:prior_qualifications
    ) as qual

)

select * from flattened
