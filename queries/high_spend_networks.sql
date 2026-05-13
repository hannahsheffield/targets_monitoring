-- Get highest spending channels in the last 6 months

WITH channels_spend AS (

  SELECT
    campaign.channel_name AS channel_name,

    COALESCE(
      SUM(campaign.cost_usd),
      0
    ) AS total_cost_usd

  FROM
    `project.dataset.campaign_performance_daily` AS campaign

  WHERE
    campaign.install_date >
      DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)

    AND campaign.acquisition_category = "Paid"

    AND campaign.acquisition_type IN (
      "Engagement",
      "N/A",
      "Re-Engagement",
      "User Acquisition"
    )

  GROUP BY
    1

  HAVING
    total_cost_usd > 0
)

SELECT
  channel_name,
  total_cost_usd

FROM
  channels_spend

WHERE
  total_cost_usd > 100000
