-- Dimension: course
-- Derived from course_enrolments — no separate source table.
-- One row per course_code.

with enrolments as (

    select * from {{ ref('stg_csv_dump__course_enrolments') }}

),

courses as (

    select distinct
        course_code,
        course_name,
        course_year_level,
        -- infer school from first two letters of course code
        case left(course_code, 2)
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
        end                    as school,
        left(course_code, 2)   as programme_code

    from enrolments

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['course_code']) }}  as course_sk,
        course_code,
        course_name,
        programme_code,
        school,
        course_year_level,
        'Undergraduate'        as level_of_study   -- extend for PG demo
    from courses

)

select * from final
