-- Intermediate: student LMS activity summary
-- Aggregates raw LMS events to student-course-week grain.
-- Used to derive engagement metrics in the academics mart.

with events as (

    select * from {{ ref('stg_json_dump__lms_events') }}

),

weekly_activity as (

    select
        student_id,
        course_code,
        date_trunc('week', event_date)      as week_start,

        -- engagement counts
        count(*)                            as total_events,
        count_if(is_login_event)            as logins,
        count_if(event_type = 'page_view')  as page_views,
        count_if(event_type = 'video_view') as video_views,
        count_if(is_assessment_event)       as assessment_events,
        count_if(event_type = 'forum_post') as forum_posts,

        -- session engagement
        sum(session_duration_seconds)       as total_session_seconds,
        avg(session_duration_seconds)       as avg_session_seconds,

        -- score (best score in week where applicable)
        max(score)                          as best_score_in_week,

        -- device split
        count_if(device_type = 'Mobile')    as mobile_events,
        count_if(device_type = 'Desktop')   as desktop_events

    from events
    group by 1, 2, 3

)

select * from weekly_activity
