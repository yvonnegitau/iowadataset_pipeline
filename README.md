# Understanding Liquor Sales in Iowa

Data source - https://data.iowa.gov/Sales-Distribution/Iowa-Liquor-Sales/m3tr-qhgy
Data Type - API call and result is a Json File
Time period - The data starts in 2021, January 1st to now. It is upated every month
Size - 23.3M rows and 24 Columns

Objective - Get State level, county level and store level report on the sales of liquor
        - Understand the most demanded liquor and is there a trend
        - Look at who is purchasing the liquor

## Stack
Cloud service - GCP
Infrastructure as code - Terraform
Workflow Orchestrator - Airflow
Data warehouse - Bigquery
Transformation tool - DBT
Dashboard - Data studio
CI/CD - Google build,Google compose


### Terraform
