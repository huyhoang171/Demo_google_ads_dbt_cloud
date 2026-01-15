# 📊 Google Ads dbt Models

This folder contains all dbt models for transforming and analyzing Google Ads data.

## 📁 Folder Structure

```
google_ads/
├── staging/          # Source data cleaning and standardization
│   ├── google_ads_sources.yml
│   ├── stg_google_ads__campaign_stats.sql
│   ├── stg_google_ads__ad_group_stats.sql
│   └── ...
│
└── mart/             # Business logic and reporting
    ├── fct_*.sql            # Fact tables (incremental)
    ├── rpt_*.sql            # Report tables (aggregated)
    ├── README.md
    ├── INCREMENTAL_GUIDE.md
    └── schema.yml
```

## 🔄 Data Flow

```
Raw BigQuery Tables (Fivetran)
       ↓
Staging Layer (staging/)
  - Clean column names
  - Standardize data types
  - Basic transformations
  - Materialized as: view
       ↓
Mart Layer (mart/)
  - Business logic
  - Calculated metrics
  - Aggregations
  - Materialized as: incremental (facts) / table (reports)
       ↓
BI Tools / Dashboards
```

## 📚 Documentation

- **Staging Layer**: [staging/README.md](staging/README.md)
- **Mart Layer**: [mart/README.md](mart/README.md)
- **Incremental Guide**: [mart/INCREMENTAL_GUIDE.md](mart/INCREMENTAL_GUIDE.md)
- **Project Configuration**: [../../../CONFIGURATION.md](../../../CONFIGURATION.md)

## 🚀 Quick Commands

```bash
# Run all Google Ads models
dbt run --models google_ads

# Run only staging
dbt run --models google_ads.staging

# Run only mart
dbt run --models google_ads.mart

# Run only fact tables (incremental)
dbt run --models google_ads.mart.fct_*

# Run only report tables
dbt run --models google_ads.mart.rpt_*

# Test all models
dbt test --models google_ads
```

## 📊 Model Counts

- **Staging Models**: 15 views
- **Fact Tables**: 5 incremental models
- **Report Tables**: 7 aggregated tables

## 🎯 Key Features

- ⚡ **Incremental Processing**: Fact tables process only recent data
- 💰 **Cost Optimized**: Significantly reduced BigQuery costs
- 🔄 **Flexible Lookback**: Configurable time windows (days/hours/minutes)
- 📈 **Budget Tracking**: Real-time budget vs spend monitoring
- 🎨 **Visualization Ready**: Pre-aggregated data for dashboards

## 🔧 Configuration

All models use centralized configuration from `dbt_project.yml`:

```yaml
models:
  google_ads_analytics:
    google_ads:
      staging:
        +materialized: view
        +schema: staging
      mart:
        +materialized: table
        +schema: mart
```

Individual models can override these settings using `{{ config(...) }}`.
