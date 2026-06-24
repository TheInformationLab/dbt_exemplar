-- Fact: course enrolments
-- Grain: one row per student-course-term enrolment
-- Kimball type: transaction fact
{{
    config(
        materialized='incremental',
        unique_key='enrolment_sk',
        incremental_strategy = 'merge'
    )
}}


with spine as (

    select 
    * 
    , greatest(enrol_loaded_at,student_loaded_at) as _loaded_at
    from {{ ref('int_student_enrolment_spine') }}
    {% if is_incremental() %}
        -- this filter will only be applied on an incremental run
        where _loaded_at > (select max(_loaded_at) from {{ this }}) 
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

, dim_term as (

    select
        term_sk
        , academic_term
    from {{ ref('dim_term') }}

)

, final as (

    select
        -- surrogate key
        
            
            {{ dbt_utils.generate_surrogate_key(['s.enrolment_id']) }}
            as enrolment_sk

        -- natural key
        , s.enrolment_id

        -- foreign keys (dimension surrogate keys)
        , d_stu.student_sk
        , d_crs.course_sk
        , d_trm.term_sk

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
    inner join dim_student as d_stu on s.student_id = d_stu.student_id
    inner join dim_course as d_crs on s.course_code = d_crs.course_code
    inner join dim_term as d_trm on s.academic_term = d_trm.academic_term

)

select * from final
