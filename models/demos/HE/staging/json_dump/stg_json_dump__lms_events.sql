-- Staging: LMS clickstream events
-- Source: lms_events.json HE_DEMO.RAW.LMS_EVENTS_RAW (VARIANT column)
-- Grain: one row per LMS event

with source as (

    select raw_json, __loaded_at from {{ source('json_dump', 'lms_events_raw') }}

)

, parsed as (

    select
        -- keys
        raw_json:event_id::varchar as event_id
        , raw_json:student_id::varchar as student_id
        , raw_json:course_code::varchar as course_code

        -- event
        , raw_json:event_type::varchar as event_type
        , raw_json:event_timestamp::timestamp_tz as event_timestamp
        , hour(raw_json:event_timestamp::timestamp_tz)::int as event_hour
        , raw_json:device_type::varchar as device_type

        -- dimensions
        , raw_json:ip_region::varchar as ip_region
        , raw_json:session_duration_seconds::int as session_duration_seconds

        -- optional metrics
        , raw_json:resource_name::varchar as resource_name
        , raw_json:score::float as score
        , date(raw_json:event_timestamp::timestamp_tz) as event_date

        -- derived flags
        , case raw_json:event_type::varchar
            when 'assignment_submit' then true
            when 'quiz_attempt' then true
            else false
        end as is_assessment_event

        , coalesce(raw_json:event_type::varchar='login', false) as is_login_event

        -- audit
        , __loaded_at as _loaded_at

    from source

)

select * from parsed
