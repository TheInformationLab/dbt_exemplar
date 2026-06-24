-- Intermediate: student enrolment spine
-- Joins staged students to their course enrolments.
-- Used as the base for academic mart models.

with students as (

    select * from {{ ref('stg_csv_dump__students') }}

)

, enrolments as (

    select * from {{ ref('stg_csv_dump__course_enrolments') }}

)

, spine as (

    select
        -- enrolment grain keys
        e.enrolment_id
        , e.student_id
        , e.lecturer_id

        -- course
        , e.course_code
        , e.course_name
        , e.course_year_level
        , e.academic_term
        , e.academic_year_start
        , e.semester_number
        , e.credits
        , e.delivery_mode
        , e.enrolment_date

        -- assessment
        , e.grade
        , e.grade_band
        , e.numeric_mark
        , e.is_pass
        , e._loaded_at as enrol_loaded_at

        -- student attributes (at point of reporting)
        , s.full_name
        , s.programme_name
        , s.programme_code
        , s.school
        , s.entry_year
        , s.current_year_of_study
        , s.enrolment_status
        , s.fee_status
        , s.gender
        , s.nationality
        , s.ethnicity
        , s.home_county
        , s.ucas_points
        , s._loaded_at as student_loaded_at

    from enrolments as e
    inner join students as s on e.student_id = s.student_id

)

select * from spine
