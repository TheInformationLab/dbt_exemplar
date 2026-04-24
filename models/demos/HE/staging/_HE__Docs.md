{% docs he_source_json_dump %}
Raw Higher Education data landed from S3 into Snowflake. JSON files are loaded into a VARIANT column and parsed in staging.
{% enddocs %}

{% docs he_source_json_dump_table_applications_raw %}
Raw admissions applications loaded from applications.json into a single VARIANT column for semi-structured parsing in staging.
{% enddocs %}

{% docs he_col_raw_application_json %}
Full admissions application JSON document stored as a Snowflake VARIANT value.
{% enddocs %}

{% docs he_source_json_dump_table_lms_events_raw %}
Raw LMS clickstream events loaded from lms_events.json into a single VARIANT column for semi-structured parsing in staging.
{% enddocs %}

{% docs he_col_raw_lms_event_json %}
Full LMS event JSON document stored as a Snowflake VARIANT value.
{% enddocs %}

{% docs he_col_first_name %}
Given name.
{% enddocs %}

{% docs he_col_last_name %}
Family name or surname.
{% enddocs %}

{% docs he_col_full_name %}
Concatenated full name built from first_name and last_name.
{% enddocs %}

{% docs he_col_gender %}
Self-reported gender identity.

Accepted values:

| value |
|---|
| Female |
| Male |
| Non-binary |
| Prefer not to say |
{% enddocs %}

{% docs he_col_nationality %}
Nationality or citizenship.
{% enddocs %}

{% docs he_col_ethnicity %}
Recorded ethnicity category.
{% enddocs %}

{% docs he_col_home_county %}
Home county recorded prior to enrolment or on application.
{% enddocs %}

{% docs he_col_email %}
Primary email address.
{% enddocs %}

{% docs he_col_programme_name %}
Full name of the academic programme.
{% enddocs %}

{% docs he_col_programme_code %}
Internal code identifying the academic programme.
{% enddocs %}

{% docs he_col_school %}
Academic school or faculty responsible for the programme.
{% enddocs %}

{% docs he_col_entry_year %}
Academic year of entry to the programme.
{% enddocs %}

{% docs he_col_date_of_birth %}
Date of birth.
{% enddocs %}

{% docs he_col_current_year_of_study %}
Current year of study within the programme.
{% enddocs %}

{% docs he_col_enrolment_status %}
Current enrolment status.

Accepted values:

| value |
|---|
| Active |
| Interrupted |
| Withdrawn |
| Graduated |
{% enddocs %}

{% docs he_col_ucas_points %}
UCAS tariff points associated with the student or application.
{% enddocs %}

{% docs he_col_personal_tutor_id %}
Identifier of the staff member assigned as the student's personal tutor.
{% enddocs %}

{% docs he_col_student_id_pk %}
Unique student identifier.
{% enddocs %}

{% docs he_col_enrolment_id %}
Unique identifier for each course enrolment record.
{% enddocs %}

{% docs he_col_fee_id %}
Unique identifier for each fee charge event.
{% enddocs %}

{% docs he_col_course_year_level %}
Programme year level associated with the course enrolment.
{% enddocs %}

{% docs he_col_credits %}
Credit value assigned to the course enrolment.
{% enddocs %}

{% docs he_col_course_code %}
Code identifying the course or module.
{% enddocs %}

{% docs he_col_course_name %}
Human-readable name of the course or module.
{% enddocs %}

{% docs he_col_student_id_fk %}
Identifier of the student associated with the record.
{% enddocs %}

{% docs he_col_academic_term %}
Academic term associated with the record.
{% enddocs %}

{% docs he_col_fee_type %}
Specific type of fee charged, such as tuition or accommodation.
{% enddocs %}

{% docs he_col_fee_category %}
Broad category used to classify the fee charge.

Accepted values:

| value |
|---|
| Academic |
| Non-Academic |
{% enddocs %}

{% docs he_col_charge_date %}
Date the fee was charged to the student account.
{% enddocs %}

{% docs he_col_currency %}
Currency code used for the amount.

Accepted values:

| value |
|---|
| GBP |
{% enddocs %}

{% docs he_col_amount_charged %}
Monetary amount charged for the fee event.
{% enddocs %}

{% docs he_col_lecturer_id %}
Identifier of the lecturer primarily responsible for the course instance.
{% enddocs %}

{% docs he_col_delivery_mode %}
Teaching delivery format for the course.

Accepted values:

| value |
|---|
| In Person |
| Hybrid |
| Online |
{% enddocs %}

{% docs he_col_grade %}
Grade or outcome recorded for the enrolment.

Accepted values:

| value |
|---|
| A* |
| A |
| B |
| C |
| D |
| F |
| In Progress |
| Withdrawn |
{% enddocs %}

{% docs he_col_enrolment_date %}
Date the student enrolled on the course.
{% enddocs %}

{% docs he_col__loaded_at %}
Timestamp when the staging model row was generated.
{% enddocs %}

{% docs he_model_stg_json_dump__applications %}
Parsed admissions applications from JSON VARIANT. One row per application. Standardizes nested applicant and programme fields, derives fee_status and conversion flags, and adds an audit timestamp.
{% enddocs %}

{% docs he_model_stg_json_dump__applications_column_application_id %}
Unique identifier for each admissions application.
{% enddocs %}

{% docs he_model_stg_json_dump__applications_column_phone %}
Applicant's contact phone number.
{% enddocs %}

{% docs he_model_stg_json_dump__applications_column_application_source %}
Channel or system through which the application was submitted.
{% enddocs %}

{% docs he_model_stg_json_dump__applications_column_application_date %}
Date the application was submitted.
{% enddocs %}

{% docs he_model_stg_json_dump__applications_column_interview_completed %}
Boolean flag indicating whether the applicant completed an interview.
{% enddocs %}

{% docs he_model_stg_json_dump__applications_column_interview_score %}
Numeric interview score awarded to the applicant.
{% enddocs %}

{% docs he_model_stg_json_dump__applications_column_outcome %}
Admissions decision or final application outcome.
{% enddocs %}

{% docs he_model_stg_json_dump__applications_column_outcome_date %}
Date the admissions outcome was recorded.
{% enddocs %}

{% docs he_model_stg_json_dump__applications_column_personal_statement_word_count %}
Word count of the submitted personal statement.
{% enddocs %}

{% docs he_model_stg_json_dump__applications_column_disability_disclosure %}
Applicant disability disclosure status captured on the application.
{% enddocs %}

{% docs he_model_stg_json_dump__applications_column_fee_status %}
Derived fee status classifying the applicant as Home or International based on nationality.

Accepted values:

| value | meaning |
|---|---|
| Home | Applicant is classified as domestic for fee purposes. |
| International | Applicant is classified as overseas for fee purposes. |
{% enddocs %}

{% docs he_model_stg_json_dump__applications_column_is_converted %}
Derived boolean flag indicating whether the application resulted in an accepted offer.
{% enddocs %}

{% docs he_model_stg_json_dump__application_qualifications %}
Prior qualifications flattened from the applications JSON array. One row per application × qualification. Standardizes qualification attributes, derives UCAS tariff points, and adds an audit timestamp.
{% enddocs %}

{% docs he_model_stg_json_dump__application_qualifications_column_application_id %}
Identifier of the parent application associated with the qualification.
{% enddocs %}

{% docs he_model_stg_json_dump__application_qualifications_column_qualification_seq %}
Zero-based sequence number of the qualification within the application's qualifications array.
{% enddocs %}

{% docs he_model_stg_json_dump__application_qualifications_column_qualification_type %}
Type of prior qualification recorded for the applicant.
{% enddocs %}

{% docs he_model_stg_json_dump__application_qualifications_column_subject %}
Subject associated with the prior qualification.
{% enddocs %}

{% docs he_model_stg_json_dump__application_qualifications_column_grade %}
Grade achieved or predicted for the qualification.
{% enddocs %}

{% docs he_model_stg_json_dump__application_qualifications_column_ucas_points %}
Derived UCAS tariff points mapped from the qualification grade.
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events %}
Parsed LMS clickstream events from JSON VARIANT. One row per event. Standardizes event attributes, derives event_date and event_hour, classifies assessment and login events, and adds an audit timestamp.
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events_column_event_id %}
Unique identifier for each LMS event.
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events_column_event_type %}
Type of LMS activity captured for the event.

Accepted values:

| value | meaning |
|---|---|
| login | User logged into the LMS. |
| page_view | User viewed a page within the LMS. |
| video_view | User viewed video content. |
| assignment_submit | User submitted an assignment. |
| quiz_attempt | User attempted a quiz. |
| forum_post | User posted in a discussion forum. |
| resource_download | User downloaded a learning resource. |
| live_session_join | User joined a live teaching session. |
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events_column_event_timestamp %}
Timestamp at which the LMS event occurred.
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events_column_event_date %}
Calendar date derived from event_timestamp.
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events_column_event_hour %}
Hour of day derived from event_timestamp in 24-hour format.
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events_column_device_type %}
Device category used when the LMS event was generated.
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events_column_ip_region %}
Geographic region inferred from the event IP address.
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events_column_session_duration_seconds %}
Session duration in seconds associated with the LMS activity, where provided.
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events_column_resource_name %}
Name of the LMS resource interacted with during the event, where applicable.
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events_column_score %}
Numeric score associated with the event, such as a quiz result, where applicable.
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events_column_is_assessment_event %}
Derived boolean flag indicating whether the event relates to an assessment activity.
{% enddocs %}

{% docs he_model_stg_json_dump__lms_events_column_is_login_event %}
Derived boolean flag indicating whether the event type is login.
{% enddocs %}

{% docs he_model_stg_csv_dump__students %}
Staged student master data. One row per student. Standardizes types, derives full_name, classifies fee_status, and adds an audit timestamp.
{% enddocs %}

{% docs he_model_stg_csv_dump__students_column_fee_status %}
Derived fee status classifying the student as Home or International based on nationality.

Accepted values:

| value | meaning |
|---|---|
| Home | Student is classified as domestic for fee purposes. |
| International | Student is classified as overseas for fee purposes. |
{% enddocs %}

{% docs he_model_stg_csv_dump__course_enrolments %}
Staged course enrolments. One row per student-course-term enrolment. Standardizes types, derives academic year and semester attributes, classifies grade_band, flags passing outcomes, and adds an audit timestamp.
{% enddocs %}

{% docs he_model_stg_csv_dump__course_enrolments_column_academic_year_start %}
Derived starting calendar year of the academic term, parsed from academic_term.
{% enddocs %}

{% docs he_model_stg_csv_dump__course_enrolments_column_semester_number %}
Derived semester number based on the academic_term pattern.

Accepted values:

| value | meaning |
|---|---|
| 1 | First semester of the academic year. |
| 2 | Second semester of the academic year. |
{% enddocs %}

{% docs he_model_stg_csv_dump__course_enrolments_column_numeric_mark %}
Numeric assessment mark for the enrolment, cast to a float.
{% enddocs %}

{% docs he_model_stg_csv_dump__course_enrolments_column_is_pass %}
Derived boolean flag indicating whether the recorded grade is considered a pass.
{% enddocs %}

{% docs he_model_stg_csv_dump__course_enrolments_column_grade_band %}
Derived grade classification bucket based on the recorded grade.

Accepted values:

| value | meaning |
|---|---|
| Distinction | Highest classification band. |
| Merit | Above-pass classification band. |
| Pass | Standard passing classification band. |
| Near Pass | Close to pass threshold but not passing. |
| Fail | Not passed. |
| In Progress | Assessment or outcome is not yet final. |
| Withdrawn | Student withdrew before completion. |
{% enddocs %}

{% docs he_model_stg_csv_dump__fee_charges %}
Staged fee charge ledger. One row per charge event. Standardizes types, derives academic year and payment_status, and adds an audit timestamp.
{% enddocs %}

{% docs he_model_stg_csv_dump__fee_charges_column_academic_year_start %}
Derived starting calendar year of the academic term, parsed from academic_term.
{% enddocs %}

{% docs he_model_stg_csv_dump__fee_charges_column_amount_paid %}
Monetary amount paid against the fee charge, cast to a float.
{% enddocs %}

{% docs he_model_stg_csv_dump__fee_charges_column_outstanding_balance %}
Remaining unpaid balance for the fee charge, cast to a float.
{% enddocs %}

{% docs he_model_stg_csv_dump__fee_charges_column_payment_plan %}
Payment plan arrangement associated with the fee charge, if applicable.
{% enddocs %}

{% docs he_model_stg_csv_dump__fee_charges_column_waiver_applied %}
Boolean flag indicating whether a fee waiver was applied to the charge.
{% enddocs %}

{% docs he_model_stg_csv_dump__fee_charges_column_payment_status %}
Derived payment classification based on charged amount and outstanding balance.

Accepted values:

| value | meaning |
|---|---|
| Fully Paid | Charge has been paid in full. |
| Partially Paid | Some payment has been received, but a balance remains. |
| Unpaid | No payment has been received against the charge. |
{% enddocs %}

{% docs he_source_csv_dump %}
Raw Higher Education data landed from S3 into Snowflake. CSV files are loaded via Snowflake external stage + COPY INTO.
{% enddocs %}

{% docs he_source_csv_dump_table_students %}
Student master record. One row per student. Loaded from students.csv.
{% enddocs %}

{% docs he_source_csv_dump_table_course_enrolments %}
One row per student-course-term enrolment. Loaded from course_enrolments.csv.
{% enddocs %}

{% docs he_source_csv_dump_table_fee_charges %}
Student fee ledger. One row per charge event. Loaded from fee_charges.csv.
{% enddocs %}


{% docs he_col_student_sk %}
Surrogate key for the student dimension row.
{% enddocs %}

{% docs he_col_course_sk %}
Surrogate key for the course dimension row.
{% enddocs %}

{% docs he_col_term_sk %}
Surrogate key for the academic term dimension row.
{% enddocs %}

{% docs he_col_enrolment_sk %}
Surrogate key for the enrolment fact row.
{% enddocs %}

{% docs he_col_lms_activity_sk %}
Surrogate key for the LMS activity fact row.
{% enddocs %}

{% docs he_col_application_sk %}
Surrogate key for the application fact row.
{% enddocs %}

{% docs he_col_fee_sk %}
Surrogate key for the fee charge fact row.
{% enddocs %}

{% docs he_col_academic_year_start %}
Starting calendar year of the academic year.
{% enddocs %}

{% docs he_col_academic_year_end %}
Ending calendar year of the academic year.
{% enddocs %}

{% docs he_col_academic_year_label %}
Display label for the academic year and semester.
{% enddocs %}

{% docs he_col_semester_number %}
Numeric semester within the academic year.

Accepted values:

| value | meaning |
|---|---|
| 1 | First semester of the academic year. |
| 2 | Second semester of the academic year. |
{% enddocs %}

{% docs he_col_semester_name %}
Name of the semester within the academic year.

Accepted values:

| value | meaning |
|---|---|
| Autumn/Winter | First semester teaching period. |
| Spring/Summer | Second semester teaching period. |
{% enddocs %}

{% docs he_col_term_start_year %}
Calendar year in which the term starts.
{% enddocs %}

{% docs he_col_term_start_month %}
Calendar month in which the term starts.

Accepted values:

| value | meaning |
|---|---|
| 9 | September term start. |
| 1 | January term start. |
{% enddocs %}

{% docs he_col_level_of_study %}
Study level associated with the course.

Accepted values:

| value |
|---|
| Undergraduate |
{% enddocs %}

{% docs he_col_entry_tariff_band %}
Banding of entry tariff points used for reporting and segmentation.

Accepted values:

| value | meaning |
|---|---|
| AAA+ | Highest entry tariff band. |
| BBB–AAB | Upper-middle entry tariff band. |
| CCC–BBC | Lower-middle entry tariff band. |
| Below CCC | Entry tariff below CCC equivalent. |
{% enddocs %}

{% docs he_measure_total_events %}
Total number of LMS events recorded in the aggregation window.
{% enddocs %}

{% docs he_measure_logins %}
Number of LMS login events recorded in the aggregation window.
{% enddocs %}

{% docs he_measure_page_views %}
Number of LMS page view events recorded in the aggregation window.
{% enddocs %}

{% docs he_measure_video_views %}
Number of LMS video view events recorded in the aggregation window.
{% enddocs %}

{% docs he_measure_assessment_events %}
Number of LMS assessment-related events recorded in the aggregation window.
{% enddocs %}

{% docs he_measure_forum_posts %}
Number of LMS discussion forum posts recorded in the aggregation window.
{% enddocs %}

{% docs he_measure_total_session_seconds %}
Total session duration in seconds across LMS activity in the aggregation window.
{% enddocs %}

{% docs he_measure_avg_session_seconds %}
Average session duration in seconds across LMS activity in the aggregation window.
{% enddocs %}

{% docs he_measure_best_score_in_week %}
Best recorded score within the weekly LMS activity window, where applicable.
{% enddocs %}

{% docs he_measure_mobile_events %}
Number of LMS events generated from mobile devices in the aggregation window.
{% enddocs %}

{% docs he_measure_desktop_events %}
Number of LMS events generated from desktop devices in the aggregation window.
{% enddocs %}

{% docs he_measure_engagement_score %}
Weighted engagement score derived from key weekly LMS activity signals.
{% enddocs %}

{% docs he_measure_application_count %}
Count measure for applications, fixed to 1 per application row.
{% enddocs %}

{% docs he_measure_converted_flag %}
Indicator showing whether the application converted to an enrolled student.

Accepted values:

| value |
|---|
| 0 |
| 1 |
{% enddocs %}

{% docs he_measure_rejected_flag %}
Indicator showing whether the application outcome is rejected.

Accepted values:

| value |
|---|
| 0 |
| 1 |
{% enddocs %}

{% docs he_measure_declined_flag %}
Indicator showing whether the applicant declined their offer.

Accepted values:

| value |
|---|
| 0 |
| 1 |
{% enddocs %}

{% docs he_measure_interviewed_flag %}
Indicator showing whether the application completed an interview.

Accepted values:

| value |
|---|
| 0 |
| 1 |
{% enddocs %}

{% docs he_measure_passed_flag %}
Indicator showing whether the enrolment is considered a pass.

Accepted values:

| value |
|---|
| 0 |
| 1 |
{% enddocs %}

{% docs he_measure_failed_flag %}
Indicator showing whether the enrolment grade is recorded as fail.

Accepted values:

| value |
|---|
| 0 |
| 1 |
{% enddocs %}

{% docs he_measure_withdrawn_flag %}
Indicator showing whether the enrolment was withdrawn.

Accepted values:

| value |
|---|
| 0 |
| 1 |
{% enddocs %}

{% docs he_measure_enrolment_count %}
Count measure for enrolments, fixed to 1 per enrolment row.
{% enddocs %}

{% docs he_measure_waiver_flag %}
Indicator showing whether a fee charge has a waiver applied.

Accepted values:

| value |
|---|
| 0 |
| 1 |
{% enddocs %}

{% docs he_measure_unpaid_flag %}
Indicator showing whether a fee charge is unpaid.

Accepted values:

| value |
|---|
| 0 |
| 1 |
{% enddocs %}

{% docs he_measure_charge_count %}
Count measure for fee charges, fixed to 1 per charge row.
{% enddocs %}


