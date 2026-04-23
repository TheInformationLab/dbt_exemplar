-- Staging: LMS clickstream events
-- Source: lms_events.json → HE_DEMO.RAW.LMS_EVENTS_RAW (VARIANT column)
-- Grain: one row per LMS event

with source as (

    select raw_json from {{ source('json_dump', 'lms_events_raw') }}

),

parsed as (

    select
        -- keys
        raw_json:event_id::varchar              as event_id,
        raw_json:student_id::varchar            as student_id,
        raw_json:course_code::varchar           as course_code,

        -- event
        raw_json:event_type::varchar            as event_type,
        raw_json:event_timestamp::timestamp_tz  as event_timestamp,
        date(raw_json:event_timestamp::timestamp_tz) as event_date,
        hour(raw_json:event_timestamp::timestamp_tz)::int as event_hour,

        -- dimensions
        raw_json:device_type::varchar           as device_type,
        raw_json:ip_region::varchar             as ip_region,

        -- optional metrics
        raw_json:session_duration_seconds::int  as session_duration_seconds,
        raw_json:resource_name::varchar         as resource_name,
        raw_json:score::float                   as score,

        -- derived flags
        case raw_json:event_type::varchar
            when 'assignment_submit' then true
            when 'quiz_attempt'      then true
            else false
        end                                     as is_assessment_event,

        case raw_json:event_type::varchar
            when 'login'             then true
            else false
        end                                     as is_login_event,

        -- audit
        current_timestamp()                     as _loaded_at

    from source

)

select * from parsed
