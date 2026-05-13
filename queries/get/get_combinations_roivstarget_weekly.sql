DECLARE MONDAY_4_MONTHS_AGO DATE DEFAULT DATE_TRUNC(
  DATE_SUB(CURRENT_DATE(), INTERVAL 4 MONTH),
  WEEK(MONDAY)
);

DECLARE SUNDAY_3_MONTHS_AGO DATE DEFAULT DATE_TRUNC(
  DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH),
  WEEK(SUNDAY)
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


weekly_roi_vs_target AS (

  SELECT
    FORMAT_DATE(
      '%F',
      DATE_TRUNC(campaign.install_date, WEEK(MONDAY))
    ) AS install_week,

    campaign.channel_name AS channel_name,
    product.product_name AS product_name,
    campaign.device_class AS device_class,
    campaign.acquisition_type AS acquisition_type,

    get_country_group(
      country.country_code
    ) AS country_group,

    COALESCE(
      SUM(campaign.cost_usd),
      0
    ) AS total_cost_usd,

    COALESCE(
      SAFE_DIVIDE(
        SUM(
          CASE
            WHEN DATE_DIFF(
              DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),
              campaign.install_date,
              DAY
            ) >= 3
            THEN campaign.revenue_4d
          END
        ),
        SUM(
          CASE
            WHEN DATE_DIFF(
              DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),
              campaign.install_date,
              DAY
            ) >= 3
            THEN campaign.cost_usd
          END
        )
      ),
      0
    )
    /
    NULLIF(
      SAFE_DIVIDE(
        SUM(campaign.cost_usd * campaign.target_pct_4d),
        SUM(campaign.cost_usd)
      ),
      0
    ) AS avg_roi_vs_target_4d,

    COALESCE(
      SAFE_DIVIDE(
        SUM(
          CASE
            WHEN DATE_DIFF(
              DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),
              campaign.install_date,
              DAY
            ) >= 89
            THEN campaign.revenue_90d
          END
        ),
        SUM(
          CASE
            WHEN DATE_DIFF(
              DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY),
              campaign.install_date,
              DAY
            ) >= 89
            THEN campaign.cost_usd
          END
        )
      ),
      0
    )
    /
    NULLIF(
      SAFE_DIVIDE(
        SUM(campaign.cost_usd * campaign.target_pct_90d),
        SUM(campaign.cost_usd)
      ),
      0
    ) AS avg_roi_vs_target_90d

  FROM
    `project.dataset.campaign_performance_daily` AS campaign

  LEFT JOIN
    `project.dataset.product_dimension` AS product
    ON campaign.product_id = product.product_id

  LEFT JOIN
    `project.dataset.country_dimension` AS country
    ON campaign.country_code = country.country_code

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

    AND product.product_name IN (
      "Game A",
      "Game B",
      "Game C",
      "Game D"
    )

    AND campaign.channel_name IN (
      SELECT channel_name
      FROM high_spend_channels
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
  weekly_roi_vs_target;
