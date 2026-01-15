# Mart Layer - Google Ads dbt Models

The mart layer contains models that have been transformed and optimized for reporting and analyzing Google Ads data.

## 📊 Model Structure

### Fact Tables
Fact tables contain detailed daily metrics with complete dimensions:

**⚡ Incremental Models** - All fact tables use `incremental` materialization with `merge` strategy for optimal performance:
- Only processes data from the **last N days** on each run (default: 3 days, configurable)
- Uses `unique_key` to update existing records and insert new ones
- Significantly reduces processing time and BigQuery costs
- Full refresh available when needed with `dbt run --full-refresh`
- **Configuration**: Adjust lookback window in `dbt_project.yml` → `vars.incremental_lookback_days`
- **See**: [INCREMENTAL_GUIDE.md](INCREMENTAL_GUIDE.md) and [CONFIGURATION.md](../../../CONFIGURATION.md) for details

1. **fct_campaign_performance**
   - Daily campaign performance
   - Includes: impressions, clicks, cost, conversions, and calculated metrics
   - Use for: Detailed performance analysis of individual campaigns
   - Unique key: `[account_id, campaign_id, stat_date, ad_network_type, device]`

2. **fct_ad_group_performance**
   - Daily ad group performance
   - Includes campaign and ad group context
   - Use for: Analyzing ad group performance within campaigns
   - Unique key: `[account_id, campaign_id, ad_group_id, stat_date, ad_network_type, device]`

3. **fct_ad_performance**
   - Daily ad performance
   - Includes full hierarchy: campaign → ad group → ad
   - Use for: Detailed performance analysis of individual ads
   - Unique key: `[account_id, campaign_id, ad_group_id, ad_id, stat_date, ad_network_type, device]`

4. **fct_keyword_performance**
   - Daily keyword performance
   - Includes keyword text and match type
   - Use for: Analyzing which keywords are performing well
   - Unique key: `[account_id, campaign_id, ad_group_id, criterion_id, stat_date, ad_network_type, device]`

5. **fct_search_term_performance**
   - Daily search term performance (actual user queries)
   - Use for: Understanding what users are searching for, finding negative keywords
   - Unique key: `[account_id, campaign_id, ad_group_id, search_term, stat_date, ad_network_type, device]`

### Report Tables
Pre-aggregated report tables for reporting:

1. **rpt_campaign_summary**
   - All-time performance summary of campaigns
   - Metrics: total cost, conversions, ROI, CTR, etc.
   - **NEW**: Budget tracking with total budget, spend %, remaining budget
   - **NEW**: Supports optional date filtering via dbt vars (`start_date`, `end_date`)
   - Use for: Campaign overview dashboard

2. **rpt_ad_group_summary**
   - All-time performance summary of ad groups
   - Use for: Comparing performance between ad groups

3. **rpt_device_performance**
   - Performance breakdown by device (Desktop, Mobile, Tablet)
   - Use for: Understanding performance differences across devices

4. **rpt_monthly_performance**
   - Monthly trends
   - Use for: Time-based trend analysis, month-over-month comparison

5. **rpt_weekly_performance** ⭐ NEW
   - Weekly performance trends (Monday-Sunday weeks)
   - Metrics: total cost, conversions, CTR, ROAS by week
   - Use for: Week-over-week comparison, weekly reporting

6. **rpt_budget_tracking** ⭐ NEW
   - Detailed budget tracking with pacing analysis
   - Metrics: daily budget, total spent, budget %, pacing status
   - Days over/under budget, average daily spend
   - Use for: Budget management and optimization

7. **rpt_budget_gauge** ⭐ NEW
   - Simplified metrics for Gauge chart visualization
   - Ad Spend vs Budget comparison
   - Multi-level views: Account, Channel, Campaign, Status
   - Color indicators for visual alerts
   - Use for: Real-time budget monitoring dashboards

## 🎯 Calculated Metrics

All fact tables include the following calculated metrics:

- **CTR (Click-Through Rate)**: `(clicks / impressions) * 100`
- **CPC (Cost Per Click)**: `cost / clicks`
- **CPM (Cost Per Mille)**: `(cost / impressions) * 1000`
- **Cost Per Conversion**: `cost / conversions`
- **Conversion Rate**: `(conversions / clicks) * 100`
- **Average Conversion Value**: `conversions_value / conversions`
- **ROAS % (Return on Ad Spend)**: `((conversions_value - cost) / cost) * 100`
- **View Rate**: `(video_views / impressions) * 100` (for video ads)
- **Viewability Rate**: `(active_view_impressions / active_view_measurable_impressions) * 100`
- **Daily Budget Spend %**: `(daily_cost / daily_budget) * 100` ⭐ NEW
- **Budget Remaining**: `daily_budget - daily_cost` ⭐ NEW

## 💰 Budget Tracking ⭐ NEW

### Budget Information
All campaign models now include budget information:
- **daily_budget**: Daily budget amount (converted from micros)
- **budget_period**: Budget period type (DAILY, CUSTOM, etc.)
- **budget_type**: Budget type (STANDARD, FIXED_CPA, etc.)
- **is_shared_budget**: Whether budget is shared across multiple campaigns

### Budget Metrics
- **daily_budget_spend_pct**: Percentage of daily budget spent
- **daily_budget_remaining**: Remaining daily budget amount
- **overall_budget_spend_pct**: Percentage of total budget spent
- **budget_status**: Budget status (Over Budget, On Track, Under Utilized, etc.)
- **pacing_status**: Pacing status (Overspending, Optimal, Underspending, etc.)

## 💰 Cost Conversion

Note: Google Ads API returns costs in **micros** (1/1,000,000 of a currency unit).
All models have converted to actual currency: `cost_micros / 1000000.0`

## 🚀 Usage Guide

### Query Examples

#### 1. Top 10 campaigns by cost
```sql
SELECT 
    campaign_name,
    total_cost,
    total_conversions,
    overall_roas_percentage
FROM {{ ref('rpt_campaign_summary') }}
ORDER BY total_cost DESC
LIMIT 10
```

#### 2. Performance by device
```sql
SELECT 
    device,
    total_impressions,
    total_clicks,
    overall_ctr,
    overall_conversion_rate
FROM {{ ref('rpt_device_performance') }}
ORDER BY total_cost DESC
```

#### 3. Monthly trends
```sql
SELECT 
    year_month,
    total_cost,
    total_conversions,
    overall_roas_percentage
FROM {{ ref('rpt_monthly_performance') }}
ORDER BY month_start_date DESC
LIMIT 12
```

#### 3b. Weekly trends ⭐ NEW
```sql
SELECT 
    year_week,
    week_start_date,
    week_end_date,
    total_cost,
    total_conversions,
    overall_ctr,
    overall_roas_percentage
FROM {{ ref('rpt_weekly_performance') }}
ORDER BY week_start_date DESC
LIMIT 12
```

#### 3c. Campaign summary with date filter ⭐ NEW
```bash
# Filter by date range (run via dbt command)
dbt run --models rpt_campaign_summary --vars '{"start_date": "2024-01-01", "end_date": "2024-12-31"}'

# Filter from date onwards
dbt run --models rpt_campaign_summary --vars '{"start_date": "2024-01-01"}'

# Filter up to date
dbt run --models rpt_campaign_summary --vars '{"end_date": "2024-12-31"}'
```

#### 4. Best performing keywords
```sql
SELECT 
    campaign_name,
    ad_group_name,
    keyword_text,
    keyword_match_type,
    SUM(impressions) as total_impressions,
    SUM(clicks) as total_clicks,
    SUM(cost) as total_cost,
    SUM(conversions) as total_conversions,
    AVG(ctr) as avg_ctr,
    AVG(conversion_rate) as avg_conversion_rate
FROM {{ ref('fct_keyword_performance') }}
WHERE stat_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY 1,2,3,4
HAVING total_clicks > 10
ORDER BY total_conversions DESC
LIMIT 20
```

#### 5. Search terms analysis (finding negative keywords)
```sql
SELECT 
    search_term,
    SUM(impressions) as total_impressions,
    SUM(clicks) as total_clicks,
    SUM(cost) as total_cost,
    SUM(conversions) as total_conversions,
    AVG(ctr) as avg_ctr,
    AVG(conversion_rate) as avg_conversion_rate
FROM {{ ref('fct_search_term_performance') }}
WHERE stat_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY 1
HAVING total_clicks > 5 AND total_conversions = 0
ORDER BY total_cost DESC
```

#### 6. Budget Tracking - Gauge Chart Data ⭐ NEW
```sql
-- Data for Gauge chart: Ad Spend vs Budget
SELECT 
    metric_name,
    total_budget,
    total_spent,
    budget_remaining,
    spend_percentage,  -- Use this for Gauge value (0-100%)
    gauge_color,       -- RED, ORANGE, GREEN, YELLOW, GRAY
    status
FROM {{ ref('rpt_budget_gauge') }}
WHERE metric_level = 'CAMPAIGN'
ORDER BY spend_percentage DESC
```

#### 7. Account-level Budget Overview
```sql
-- Budget overview for entire account
SELECT 
    metric_name as account,
    total_budget,
    total_spent,
    budget_remaining,
    spend_percentage,
    status
FROM {{ ref('rpt_budget_gauge') }}
WHERE metric_level = 'ACCOUNT_TOTAL'
```

#### 8. Budget Tracking with Pacing Analysis
```sql
-- Detailed budget and pacing analysis
SELECT 
    campaign_name,
    budget_name,
    daily_budget,
    total_budget_allocated,
    total_spent,
    budget_spent_pct,
    avg_daily_spend,
    avg_daily_pacing_pct,
    days_over_budget,
    days_under_utilized,
    budget_status,
    pacing_status
FROM {{ ref('rpt_budget_tracking') }}
WHERE campaign_status = 'ENABLED'
ORDER BY budget_spent_pct DESC
```

#### 9. Campaigns Over Budget
```sql
-- Campaigns currently over budget
SELECT 
    campaign_name,
    total_budget_allocated,
    total_spent,
    budget_spent_pct,
    total_spent - total_budget_allocated as over_budget_amount,
    budget_status
FROM {{ ref('rpt_budget_tracking') }}
WHERE budget_status = 'OVER_BUDGET'
ORDER BY over_budget_amount DESC
```

#### 10. Budget by Channel
```sql
-- Compare budget utilization by channel
SELECT 
    metric_name as channel,
    total_budget,
    total_spent,
    spend_percentage,
    gauge_color,
    status
FROM {{ ref('rpt_budget_gauge') }}
WHERE metric_level = 'CHANNEL'
ORDER BY spend_percentage DESC
```

## 📈 Best Practices for Reporting

1. **Time-based Analysis**: Use `stat_date` to filter by specific time periods
2. **Hierarchy Drill-down**: Campaign → Ad Group → Ad/Keyword for detailed analysis
3. **Device Comparison**: Compare performance across devices
4. **Search Term Mining**: Regularly review search terms to find:
   - New keyword opportunities
   - Negative keywords to add
5. **Trend Analysis**: Use monthly reports to track performance over time
6. **Budget Monitoring** ⭐ NEW:
   - Use `rpt_budget_gauge` for Gauge chart visualization
   - Monitor campaigns with `budget_status = 'OVER_BUDGET'`
   - Track pacing with `rpt_budget_tracking`
   - Set alerts when `spend_percentage >= 90%`

## 📊 Gauge Chart Setup Guide ⭐ NEW

### Looker Studio / Power BI / Tableau
```
Data Source: rpt_budget_gauge
Metric: spend_percentage
Dimension: metric_name
Filter: metric_level = 'CAMPAIGN' (or 'ACCOUNT_TOTAL' for overview)

Gauge Settings:
- Min: 0
- Max: 100
- Green Zone: 0-70 (On Track)
- Yellow Zone: 70-90 (Acceptable)
- Orange Zone: 90-95 (Near Limit)
- Red Zone: 95-100+ (Over Budget)

Display Labels:
- Value: spend_percentage + "%"
- Label 1: metric_name
- Label 2: total_spent + " / " + total_budget
```

### Example Visualization Structure
```
┌─────────────────────────────────────┐
│   Account Budget Overview           │
│   ┌─────────────────────────┐      │
│   │  Gauge: 78.5%          │      │
│   │  $78,500 / $100,000    │      │
│   └─────────────────────────┘      │
└─────────────────────────────────────┘

┌──────────────┬──────────────┬───────────────┐
│ Campaign A   │ Campaign B   │ Campaign C    │
│ Gauge: 95%   │ Gauge: 82%   │ Gauge: 65%   │
│ Near Limit   │ On Track     │ On Track     │
└──────────────┴──────────────┴───────────────┘
```

## 🔄 Refresh Schedule

### Fact Tables (Incremental)
- **Daily runs**: Process only last 3 days of data (incremental updates)
- **Run time**: ~Minutes (vs hours for full refresh)
- **Command**: `dbt run --models fct_*`
- **Full refresh** (if needed): `dbt run --models fct_* --full-refresh`

### Report Tables (Full Refresh)
- **Daily runs**: Recompute all aggregations from fact tables
- **Run time**: Fast, since fact tables are pre-computed
- **Command**: `dbt run --models rpt_*`

### Incremental Strategy Benefits
- ⚡ **Faster**: Only processes 3 days instead of entire history
- 💰 **Cheaper**: Significantly reduced BigQuery costs
- 🔄 **Late data handling**: 3-day lookback captures late-arriving data
- 🎯 **Merge strategy**: Updates existing records if data changes

### When to Full Refresh
Run `dbt run --full-refresh` when:
- Initial setup or migration
- Schema changes to models
- Data quality issues requiring reprocessing
- Backfilling historical data

## 📝 Notes

- **Fact Tables**: Use `incremental` materialization with 3-day lookback window
- **Report Tables**: Use `table` materialization (full refresh each run)
- All costs have been converted from micros to actual currency
- Only uses active records (`is_active = true`) from history tables
- Metrics are calculated with safe division (prevents division by zero)
- Supports Active View metrics for display campaigns
