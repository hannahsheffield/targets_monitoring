-- Get highest spending countries in the last 6 months

WITH countries_spend AS (

  SELECT
    country.country_code AS country_code,

    COALESCE(
      SUM(campaign.cost_usd),
      0
    ) AS total_cost_usd

  FROM
    `project.dataset.campaign_performance_daily` AS campaign

  LEFT JOIN
    `project.dataset.country_dimension` AS country
    ON campaign.country_code = country.country_code

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
  country_code,
  total_cost_usd

FROM
  countries_spend

WHERE
  total_cost_usd > 100000
