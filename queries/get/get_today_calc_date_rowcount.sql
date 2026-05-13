SELECT
    COUNT(*) AS count_rows

FROM
    `your-gcp-project-id.monitoring_dataset.performance_scores_v3`

WHERE
    calc_date = CURRENT_DATE()
