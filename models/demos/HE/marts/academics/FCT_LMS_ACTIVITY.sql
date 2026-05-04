-- Fact: LMS weekly engagement activity
-- Grain: one row per student-course-week
-- Kimball type: periodic snapshot fact
{{
    config(
        materialized='incremental',
        unique_key='lms_activity_sk',
        incremental_strategy = 'insert_overwrite'
    )
}}


with activity as (

    select * from {{ ref('int_student_lms_activity') }}

),

DIM_STUDENT as (

    select student_sk, student_id from {{ ref('DIM_STUDENT') }}

),

DIM_COURSE as (

    select course_sk, course_code from {{ ref('DIM_COURSE') }}

),

final as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['a.student_id','a.course_code','a.week_start']) }}
            as lms_activity_sk,

        -- foreign keys
        d_stu.student_sk,
        d_crs.course_sk,

        -- degenerate date dimension
        a.week_start,

        -- engagement measures
        a.total_events,
        a.logins,
        a.page_views,
        a.video_views,
        a.assessment_events,
        a.forum_posts,
        a.total_session_seconds,
        a.avg_session_seconds,
        a.best_score_in_week,
        a.mobile_events,
        a.desktop_events,

        -- derived engagement score (demo metric — weight as preferred)
        round(
            (a.logins          * 2)
          + (a.page_views      * 1)
          + (a.video_views     * 3)
          + (a.assessment_events * 5)
          + (a.forum_posts     * 4)
        , 0)                           as engagement_score

    from activity a
    inner join DIM_STUDENT d_stu on a.student_id  = d_stu.student_id
    inner join DIM_COURSE  d_crs on a.course_code = d_crs.course_code

)

select * from final
