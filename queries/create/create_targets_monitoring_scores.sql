CREATE OR REPLACE TABLE
  `your-gcp-project-id.monitoring_dataset.performance_scores` (

    product_name STRING NOT NULL,
    channel_name STRING NOT NULL,
    device_class STRING NOT NULL,

    acquisition_type STRING NOT NULL,

    total_cost_usd FLOAT64 NOT NULL,
    pct_total_cost_usd FLOAT64 NOT NULL,
    cost_score FLOAT64 NOT NULL,

    avg_abs_metric_change FLOAT64 NOT NULL,
    metric_absolute_score FLOAT64 NOT NULL,

    stddev_abs_metric_change FLOAT64 NOT NULL,
    count_time_periods INT64 NOT NULL,

    metric_volatility FLOAT64 NOT NULL,
    volatility_score FLOAT64 NOT NULL,

    periods_above_threshold INT64 NOT NULL,
    duration_score FLOAT64 NOT NULL,

    review_priority_score FLOAT64 NOT NULL,

    calc_date DATE NOT NULL
)

PARTITION BY
  calc_date

OPTIONS (
  require_partition_filter = TRUE
)
