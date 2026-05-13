-- Get weekly cost by reporting combination

DECLARE MONDAY_4_MONTHS_AGO DATE DEFAULT DATE_TRUNC(
  DATE_SUB(CURRENT_DATE(), INTERVAL 4 MONTH),
  WEEK(MONDAY)
);

DECLARE SUNDAY_3_MONTHS_AGO DATE DEFAULT DATE_TRUNC(
  DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH),
  WEEK(SUNDAY)
);


CREATE TEMP FUNCTION get_week_monday_from_date(from_date DATE)
RETURNS DATE
AS (
  DATE(FORMAT_DATE('%F', DATE_TRUNC(from_date, WEEK(MONDAY))))
);


CREATE TEMP FUNCTION get_country_group(country_code STRING)
RETURNS STRING
AS (
  CASE
    WHEN country_code IN ("US", "DE", "FR", "GB", "CA", "AU", "JP")
    THEN country_code
    ELSE "other"
  END
);


WITH high_spend_channels AS (

  SELECT
    channel_name

  FROM
    `your-gcp-project-id.monitoring_dataset.high_spend_channels`

  WHERE
    channel_name NOT IN ("network_x", "network_y", "network_z")
),


weekly_combination_costs AS (

  SELECT
    campaign.channel_name AS channel_name,
    product.product_name AS product_name,

    get_country_group(
      campaign.country_code
    ) AS country_group,

    campaign.device_class AS device_class,
    campaign.acquisition_type AS acquisition_type,

    get_week_monday_from_date(
      campaign.install_date
    ) AS install_week,

    SUM(
      COALESCE(campaign.cost_usd, 0)
    ) AS total_cost_usd

  FROM
    `project.dataset.campaign_performance_daily` AS campaign

  LEFT JOIN
    `project.dataset.product_dimension` AS product
    USING (product_id)

  WHERE
    campaign.install_date BETWEEN
      MONDAY_4_MONTHS_AGO
      AND SUNDAY_3_MONTHS_AGO

    AND campaign.acquisition_category = "Paid"

    AND campaign.acquisition_type IN (
      "Engagement",
      "N/A",
      "Re-Engagement",
      "User Acquisition"
    )

    AND campaign.channel_name IN (
      SELECT channel_name
      FROM high_spend_channels
    )

    AND product.product_name IN (
      "Game A",
      "Game B",
      "Game C",
      "Game D"
    )

  GROUP BY
    1,2,3,4,5,6

  HAVING
    total_cost_usd > 10000
)


SELECT
  *,
  MONDAY_4_MONTHS_AGO AS reporting_window_start_date,
  SUNDAY_3_MONTHS_AGO AS reporting_window_end_date

FROM
  weekly_combination_costs;
