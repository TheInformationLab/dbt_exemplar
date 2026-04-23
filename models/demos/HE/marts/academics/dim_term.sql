-- Dimension: academic term
-- Conformed dimension shared across all three mart domains.
-- Seeded from the distinct terms present in enrolments + fees.

with terms_from_enrolments as (
    select distinct academic_term from {{ ref('stg_csv_dump__course_enrolments') }}
),

terms_from_fees as (
    select distinct academic_term from {{ ref('stg_csv_dump__fee_charges') }}
),

all_terms as (
    select academic_term from terms_from_enrolments
    union
    select academic_term from terms_from_fees
),

enriched as (

    select
        {{ dbt_utils.generate_surrogate_key(['academic_term']) }} as term_sk,
        academic_term,

        -- parse components from "YYYY/YY SN" format
        split_part(academic_term, '/', 1)::int      as academic_year_start,
        ('20' || split_part(split_part(academic_term, '/', 2), ' ', 1))::int
                                                    as academic_year_end,
        academic_term || ''                         as academic_year_label,

        case
            when academic_term ilike '%S1%' then 1
            when academic_term ilike '%S2%' then 2
        end                                         as semester_number,

        case
            when academic_term ilike '%S1%' then 'Autumn/Winter'
            when academic_term ilike '%S2%' then 'Spring/Summer'
        end                                         as semester_name,

        -- approximate term start/end months
        case
            when academic_term ilike '%S1%' then split_part(academic_term, '/', 1)::int
            else split_part(academic_term, '/', 1)::int + 1
        end                                         as term_start_year,

        case
            when academic_term ilike '%S1%' then 9
            else 1
        end                                         as term_start_month

    from all_terms

)

select * from enriched
