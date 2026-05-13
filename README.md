<a name="readme-top"></a>

<div align="center">

  <h1>Performance Target Monitoring Pipeline</h1>

  <p>
    <strong>An anonymised BigQuery, Python, and dashboarding project for monitoring model-generated performance targets.</strong>
  </p>

  <p>
    <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" />
    <img src="https://img.shields.io/badge/Pandas-150458?style=for-the-badge&logo=pandas&logoColor=white" />
    <img src="https://img.shields.io/badge/NumPy-013243?style=for-the-badge&logo=numpy&logoColor=white" />
    <img src="https://img.shields.io/badge/BigQuery-669DF6?style=for-the-badge&logo=googlecloud&logoColor=white" />
    <img src="https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=postgresql&logoColor=white" />
  </p>

</div>

---

## Overview

Performance Target Monitoring Pipeline is an anonymised analytics engineering project designed to monitor the accuracy and stability of model-generated marketing performance targets.

The project calculates a review priority score for each reporting combination, helping teams identify which channel, product, country, device, and acquisition-type combinations may need target review.

> This is a portfolio-safe version of a workplace monitoring project. It uses generic names, placeholder table references, mock examples, and anonymised business logic. No proprietary data, internal URLs, credentials, stakeholder names, or confidential company logic are included.

---

## Problem

Performance targets are used to guide marketing investment decisions, but model-generated targets can drift or become less accurate over time.

Common challenges include:

<ul>
  <li>Large numbers of channel and product combinations to monitor</li>
  <li>Different performance behaviour across countries, devices, and acquisition types</li>
  <li>Difficulty identifying which targets most urgently need review</li>
  <li>Manual monitoring of short-term versus longer-term performance</li>
  <li>Need to prioritise high-spend combinations first</li>
</ul>

Without a prioritisation framework, target review can become reactive, manual, and difficult to scale.

---

## Solution

This project creates a scoring workflow that monitors model target accuracy and ranks combinations by review priority.

The workflow:

<ol>
  <li>Pulls weekly spend by reporting combination</li>
  <li>Pulls short-term and longer-term performance-vs-target metrics</li>
  <li>Calculates cost share and cost score</li>
  <li>Calculates absolute metric change between short-term and longer-term performance</li>
  <li>Measures volatility of target accuracy over time</li>
  <li>Measures duration of sustained target deviation</li>
  <li>Combines all components into a final review priority score</li>
  <li>Checks whether the daily run has already completed</li>
  <li>Uploads scored results to a partitioned BigQuery table</li>
</ol>

---

## Tech Stack

<table>
  <tr>
    <th>Tool</th>
    <th>Purpose</th>
  </tr>
  <tr>
    <td>Python</td>
    <td>Main scoring workflow</td>
  </tr>
  <tr>
    <td>Pandas</td>
    <td>Data transformation, grouping, merging, and formatting</td>
  </tr>
  <tr>
    <td>NumPy</td>
    <td>Scoring logic and conditional calculations</td>
  </tr>
  <tr>
    <td>BigQuery</td>
    <td>Source data extraction and score table storage</td>
  </tr>
  <tr>
    <td>SQL</td>
    <td>Weekly cost, ROI-vs-target, and high-spend dimension queries</td>
  </tr>
  <tr>
    <td>Dashboarding Tool</td>
    <td>Final monitoring dashboard for stakeholder review</td>
  </tr>
</table>

---

## Scoring Methodology

The final <strong>Review Priority Score</strong> combines four components.

<table>
  <tr>
    <th>Component</th>
    <th>Score Range</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><strong>Cost Score</strong></td>
    <td>0–3</td>
    <td>Prioritises high-spend combinations by calculating each combination's share of total cost.</td>
  </tr>
  <tr>
    <td><strong>Absolute Metric Change Score</strong></td>
    <td>0–2</td>
    <td>Measures average absolute difference between short-term and longer-term target performance.</td>
  </tr>
  <tr>
    <td><strong>Volatility Score</strong></td>
    <td>0–3</td>
    <td>Measures how unstable the metric change is over time.</td>
  </tr>
  <tr>
    <td><strong>Duration Score</strong></td>
    <td>0–2</td>
    <td>Measures whether target deviation persists across multiple weeks.</td>
  </tr>
</table>

The final score is calculated as:

```text
Review Priority Score =
  Cost Score
+ Absolute Metric Change Score
+ Volatility Score
+ Duration Score
