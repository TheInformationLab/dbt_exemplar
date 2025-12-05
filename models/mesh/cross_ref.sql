SELECT 
    cancer_type_detailed,
    SUM(survived)/COUNT(patient_id) as percent_survived,
    COUNT(patient_id) as cases
FROM {{ ref('core_consulting','report_cancer_survival') }}
GROUP BY cancer_type_detailed
HAVING cases > 100
ORDER BY percent_survived DESC