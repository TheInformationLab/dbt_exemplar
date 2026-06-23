-- Staging: course enrolments
-- Source: course_enrolments.csv → HE_DEMO.RAW.COURSE_ENROLMENTS
-- Grain: one row per student-course-term

with source as (

    select * from {{ source('csv_dump', 'course_enrolments') }}

)

, renamed as (

    select
        -- keys
        enrolment_id
        , student_id
        , lecturer_id

        -- course
        , course_code
        , course_name
        , course_year_level::int as course_year_level

        -- term
        , academic_term
        -- derive academic year (e.g. "2023/24 S1" → 2023)
        , split_part(academic_term, '/', 1)::int as academic_year_start
        , credits::int as credits

        -- enrolment attributes
        , delivery_mode
        , enrolment_date::date as enrolment_date
        , grade

        -- assessment
        , numeric_mark::float as numeric_mark
        , case
            when academic_term ilike '%S1%' then 1
            when academic_term ilike '%S2%' then 2
        end as semester_number

        -- derived flags
        , coalesce (grade in ('A*', 'A', 'B', 'C'), false) as is_pass

        , case
            when grade in ('A*', 'A') then 'Distinction'
            when grade = 'B' then 'Merit'
            when grade = 'C' then 'Pass'
            when grade = 'D' then 'Near Pass'
            when grade = 'F' then 'Fail'
            when grade = 'In Progress' then 'In Progress'
            else 'Withdrawn'
        end as grade_band

        -- audit
        , __loaded_at as _loaded_at

    from source

)

select * from renamed

