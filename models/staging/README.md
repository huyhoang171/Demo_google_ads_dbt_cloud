# Google Ads Staging Models

This directory contains dbt staging models for Google Ads data synced via Fivetran.

## Overview

The staging layer provides a clean, consistent interface to the raw Google Ads data. All models follow these conventions:

- **Naming**: `stg_google_ads__<table_name>`
- **Materialization**: Views (for freshness and storage efficiency)
- **Column naming**: Renamed for clarity and consistency
- **ID columns**: Suffixed with `_id` (e.g., `account_id`, `campaign_id`)
- **Boolean columns**: Prefixed with `is_` (e.g., `is_active`, `is_hidden`)
- **Timestamp columns**: Clearly named (e.g., `stat_date`, `updated_at`)

## Data Source

All models source from the `google_ads` source defined in `google_ads_sources.yml`. The source contains 91 tables organized into the following categories:

### Core Entity Tables

#### Account Tables
- `stg_google_ads__account_history` - Account configuration and settings
- `stg_google_ads__account_stats` - Daily account performance metrics
- `stg_google_ads__account_hourly_stats` - Hourly account performance metrics

#### Campaign Tables
- `stg_google_ads__campaign_history` - Campaign configuration and settings
- `stg_google_ads__campaign_stats` - Daily campaign performance metrics
- `stg_google_ads__campaign_budget_history` - Campaign budget information
- Additional campaign setting tables (bidding, targeting, network, etc.)

#### Ad Group Tables
- `stg_google_ads__ad_group_history` - Ad group configuration and settings
- `stg_google_ads__ad_group_stats` - Daily ad group performance metrics
- `stg_google_ads__ad_group_criterion_history` - Keywords and targeting criteria

#### Ad Tables
- `stg_google_ads__ad_history` - Ad configuration and settings
- `stg_google_ads__ad_stats` - Daily ad performance metrics
- Ad type-specific tables (responsive search, responsive display, video, etc.)

### Performance Stats Tables

- `stg_google_ads__keyword_stats` - Keyword-level performance
- `stg_google_ads__search_term_stats` - Search term performance
- `stg_google_ads__audience_stats` - Audience performance
- `stg_google_ads__landing_page_stats` - Landing page performance

### Reference/Dimension Tables

- `stg_google_ads__geo_target` - Geographic targeting constants
- `stg_google_ads__user_list` - Remarketing list definitions
- `stg_google_ads__label` - Label definitions
- `stg_google_ads__topic` - Topic targeting constants
- `stg_google_ads__user_interest` - User interest categories

## Schema Information

The complete schema was extracted from the CSV file `bquxjob_13cad203_19bb6a6a58b.csv` which contains:
- **91 unique tables**
- **1,305 total columns** across all tables
- Column metadata including data types and nullability

## Important Notes

### Cost Metrics
All cost metrics are stored in **micros** (1/1,000,000 of the currency unit). To get the actual cost:
```sql
cost_micros / 1000000.0 as cost
```

### Fivetran Columns
All tables include Fivetran metadata columns:
- `_fivetran_synced` - When the row was last synced
- `_fivetran_active` - Whether the row is currently active (for history tables)
- `_fivetran_start` - Start of validity period (for history tables)
- `_fivetran_end` - End of validity period (for history tables)

### History Tables
Tables ending in `_history` track changes over time using Fivetran's change data capture. Use `_fivetran_active = true` to get current records.

## Configuration Required

Before using these models, update the following in `google_ads_sources.yml`:
1. **database**: Set to your BigQuery project ID
2. **schema**: Set to your Google Ads schema name (e.g., `google_ads_fivetran`)

## Usage Example

```sql
-- Get active campaigns with their budgets
select
    c.campaign_id,
    c.campaign_name,
    c.campaign_status,
    b.amount_micros / 1000000.0 as daily_budget,
    c.currency_code
from {{ ref('stg_google_ads__campaign_history') }} c
left join {{ ref('stg_google_ads__campaign_budget_history') }} b
    on c.campaign_id = b.campaign_id
    and b.is_active = true
where c.is_active = true
    and c.campaign_status = 'ENABLED'
```

## Models Created

The following staging models have been created:

1. `stg_google_ads__account_history.sql`
2. `stg_google_ads__account_stats.sql`
3. `stg_google_ads__campaign_history.sql`
4. `stg_google_ads__campaign_stats.sql`
5. `stg_google_ads__campaign_budget_history.sql`
6. `stg_google_ads__ad_group_history.sql`
7. `stg_google_ads__ad_group_stats.sql`
8. `stg_google_ads__ad_group_criterion_history.sql`
9. `stg_google_ads__ad_history.sql`
10. `stg_google_ads__ad_stats.sql`
11. `stg_google_ads__keyword_stats.sql`
12. `stg_google_ads__responsive_search_ad_history.sql`
13. `stg_google_ads__search_term_stats.sql`
14. `stg_google_ads__geo_target.sql`
15. `stg_google_ads__user_list.sql`

