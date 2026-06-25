WITH fct_lms_activity AS (
  /* Periodic snapshot fact at student-course-week grain. Captures LMS engagement metrics used for academic engagement analysis.
*/
  SELECT
    *
  FROM {{ ref('dbt_exemplar', 'fct_lms_activity') }}
), aggregate_1 AS (
  SELECT
    STUDENT_SK,
    COURSE_SK,
    SUM(TOTAL_EVENTS) AS TOTAL_EVENTS
  FROM fct_lms_activity
  GROUP BY
    STUDENT_SK,
    COURSE_SK
), "order" AS (
  SELECT
    *
  FROM aggregate_1
  ORDER BY
    TOTAL_EVENTS DESC
  LIMIT 5
), projection AS (
  SELECT
    TOTAL_EVENTS AS Top_5_total_events,
    *
    EXCLUDE (TOTAL_EVENTS)
  FROM "order"
), top_five_events_sql AS (
  SELECT
    *
  FROM projection
)
SELECT
  *
FROM top_five_events_sql