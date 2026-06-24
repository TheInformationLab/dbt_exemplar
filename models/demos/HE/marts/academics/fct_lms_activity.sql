-- Fact: LMS weekly engagement activity
-- Grain: one row per student-course-week
-- Kimball type: periodic snapshot fact
{{
    config(
        materialized='incremental',
        unique_key='lms_activity_sk',
        incremental_strategy = 'merge'
    )
}}


with activity as (

    select * from {{ ref('int_student_lms_activity') }}
    {% if is_incremental() %}
        -- this filter will only be applied on an incremental run
        where _loaded_at > (
            select coalesce(max(existing._loaded_at), '1900-01-01'::timestamp)
            from {{ this }} as existing
        )
    {% endif %}

)

, dim_student as (

    select
        student_sk
        , student_id
    from {{ ref('dim_student') }}

)

, dim_course as (

    select
        course_sk
        , course_code
    from {{ ref('dim_course') }}

)

, final as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(
        ['a.student_id'
        ,'a.course_code'
        ,'a.week_start']) }}
            as lms_activity_sk

        -- foreign keys
        , d_stu.student_sk
        , d_crs.course_sk

        -- degenerate date dimension
        , a.week_start

        -- engagement measures
        , a.total_events
        , a.logins
        , a.page_views
        , a.video_views
        , a.assessment_events
        , a.forum_posts
        , a.total_session_seconds
        , a.avg_session_seconds
        , a.best_score_in_week
        , a.mobile_events
        , a.desktop_events

        -- derived engagement score (demo metric — weight as preferred)
        , round(
            (a.logins * 2)
            + (a.page_views * 1)
            + (a.video_views * 3)
            + (a.assessment_events * 5)
            + (a.forum_posts * 4)
            , 0
        ) as engagement_score
        , a._loaded_at

    from activity as a
    inner join dim_student as d_stu on a.student_id = d_stu.student_id
    inner join dim_course as d_crs on a.course_code = d_crs.course_code

)

select * from final
