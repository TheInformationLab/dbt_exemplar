-- Fact: admissions applications
-- Grain: one row per application
-- Kimball type: transaction fact
-- Domain: admissions mart

with applications as (

    select * from {{ ref('stg_json_dump__applications') }}

),

DIM_STUDENT as (

    -- left join: applicants may not have become students
    select student_sk, student_id, email from {{ ref('DIM_STUDENT') }}

),

DIM_TERM as (

    select term_sk, academic_term from {{ ref('DIM_TERM') }}

),

final as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['a.application_id']) }} as application_sk,

        -- natural key
        a.application_id,

        -- foreign keys
        d_stu.student_sk,   -- null if applicant did not convert to enrolled student
        d_trm.term_sk,

        -- applicant attributes (role-playing dimension — no separate dim_applicant)
        a.full_name,
        a.gender,
        a.nationality,
        a.ethnicity,
        a.home_county,
        a.fee_status,
        a.disability_disclosure,

        -- programme applied for
        a.programme_name,
        a.programme_code,
        a.school,
        a.entry_year,

        -- application journey
        a.application_source,
        a.application_date,
        a.ucas_points,
        a.personal_statement_word_count,

        -- interview
        a.interview_completed,
        a.interview_score,

        -- outcome
        a.outcome,
        a.outcome_date,
        a.is_converted,

        -- additive measures
        1                                                       as application_count,
        case when a.is_converted then 1 else 0 end              as converted_flag,
        case when a.outcome = 'Rejected' then 1 else 0 end      as rejected_flag,
        case when a.outcome = 'Offer Declined' then 1 else 0 end as declined_flag,
        case when a.interview_completed then 1 else 0 end       as interviewed_flag

    from applications a
    left  join DIM_STUDENT d_stu
        on a.email = d_stu.email
    left  join DIM_TERM d_trm
        on a.entry_year::varchar || '/24 S1' = d_trm.academic_term  -- approximate join for demo

)

select * from final
