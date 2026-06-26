with enrolments as (

    select * from {{ ref('stg_csv_dump__course_enrolments') }}

)

, courses as (

    select distinct
        course_code
        , course_name
        , course_year_level
        -- infer school from first two letters of course code
        , case left(course_code, 2)
            when 'CS' then 'School of Computing'
            when 'DS' then 'School of Computing'
            when 'EC' then 'School of Business'
            when 'NU' then 'School of Health Sciences'
            when 'ME' then 'School of Engineering'
            when 'EL' then 'School of Humanities'
            when 'PY' then 'School of Social Sciences'
            when 'LW' then 'School of Law'
            when 'BM' then 'School of Health Sciences'
            when 'HI' then 'School of Humanities'
            else 'Unknown'
        end as school
        , left(course_code, 2) as programme_code

    from enrolments

)

, dm_course as (

    select
        {{ dbt_utils.generate_surrogate_key(['course_code']) }} as course_sk
        , course_code
        , course_name
        , programme_code
        , school
        , course_year_level
        , 'Undergraduate' as level_of_study   -- extend for PG demo
        -- , Case when course_name = 'Databases' THEN 'Postgraduate' ELSE 'Undergraduate' END as level_of_study

    from courses

)

, spine as (

    select
        *
        , greatest(enrol_loaded_at, student_loaded_at) as _loaded_at
    from {{ ref('int_student_enrolment_spine') }}
    {% if is_incremental() %}
        -- this filter will only be applied on an incremental run
        where _loaded_at > (
            select coalesce(max(existing._loaded_at), '1900-01-01'::timestamp)
            from {{ this }} as existing
        )
    {% endif %}

)

, dim_course as (

    select
        course_sk
        , course_code
    from dm_course

)


, joined as (

    select
        -- surrogate key


        {{ dbt_utils.generate_surrogate_key(['s.enrolment_id']) }}
            as enrolment_sk

        -- natural key
        , s.enrolment_id

        -- foreign keys (dimension surrogate keys)

        , d_crs.course_sk
        , d_crs.course_code

        -- degenerate dimensions
        , s.lecturer_id
        , s.delivery_mode

        -- dates
        , s.enrolment_date

        -- measures
        , s.credits
        , s.numeric_mark

        -- categorical performance attributes
        , s.grade
        , s.grade_band

        -- additive binary measures
        , case when s.is_pass then 1 else 0 end as passed_flag
        , case when s.grade = 'F' then 1 else 0 end as failed_flag
        , case when s.grade = 'Withdrawn' then 1 else 0 end as withdrawn_flag
        , 1 as enrolment_count
        , s._loaded_at

    from spine as s
    inner join dim_course as d_crs on s.course_code = d_crs.course_code

)

, final as (
    select
        course_code
        , delivery_mode
        , sum(passed_flag) as total_passes
        , sum(failed_flag) as total_failed
        , sum(withdrawn_flag) as total_withdrawn
        , sum(enrolment_count) as total_enrolled
    from joined
    group by 1, 2
)

select * from final
order by total_enrolled desc