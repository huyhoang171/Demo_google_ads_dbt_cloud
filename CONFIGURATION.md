# ⚙️ Configuration Guide

This document explains how to configure the project's behavior through variables and settings.

## 📋 Overview

Key configurations are centralized in `dbt_project.yml` for easy management.

## 🔧 Incremental Lookback Window

### Location
File: `dbt_project.yml`

```yaml
vars:
  # Option 1: Days (default - recommended for most cases)
  incremental_lookback_days: 3
  
  # Option 2: Hours (for real-time/hourly updates)
  # incremental_lookback_hours: 12
  
  # Option 3: Minutes (for near-real-time data)
  # incremental_lookback_minutes: 30
```

### What It Does
Controls how much historical data to reprocess on each incremental run.

**Priority order:** If multiple values are set:
1. Minutes (highest priority - most granular)
2. Hours
3. Days (default if nothing else is set)

**Examples:**

**Days:** If set to `3`:
- Running on Jan 15 will process data from Jan 13, 14, 15
- Running on Jan 16 will process data from Jan 14, 15, 16

**Hours:** If set to `12`:
- Running at 2:00 PM will process data from 2:00 AM onwards
- Running at 8:00 PM will process data from 8:00 AM onwards

**Minutes:** If set to `30`:
- Running at 2:30 PM will process data from 2:00 PM onwards
- Running at 3:45 PM will process data from 3:15 PM onwards

### How to Change

#### Option 1: Edit dbt_project.yml (Permanent)

**Use Days (Default):**
```yaml
vars:
  incremental_lookback_days: 3  # Process last 3 days
```

**Use Hours (Hourly Updates):**
```yaml
vars:
  # incremental_lookback_days: 3  # Comment out days
  incremental_lookback_hours: 12   # Process last 12 hours
```

**Use Minutes (Real-time):**
```yaml
vars:
  # incremental_lookback_days: 3      # Comment out days
  # incremental_lookback_hours: 12    # Comment out hours
  incremental_lookback_minutes: 30    # Process last 30 minutes
```

#### Option 2: Command Line Override (One-time)

**Days:**
```bash
dbt run --models fct_* --vars '{"incremental_lookback_days": 5}'
```

**Hours:**
```bash
# Process last 24 hours
dbt run --models fct_* --vars '{"incremental_lookback_hours": 24}'

# Process last 6 hours (for real-time dashboards)
dbt run --models fct_* --vars '{"incremental_lookback_hours": 6}'
```

**Minutes:**
```bash
# Process last 60 minutes
dbt run --models fct_* --vars '{"incremental_lookback_minutes": 60}'

# Process last 15 minutes (for near-real-time)
dbt run --models fct_* --vars '{"incremental_lookback_minutes": 15}'
```

#### Option 3: Environment-Specific (profiles.yml)
```yaml
# profiles.yml
google_ads:
  outputs:
    dev:
      type: bigquery
      project: your-project
      vars:
        incremental_lookback_days: 7  # Dev uses longer window
    
    prod:
      type: bigquery
      project: your-project
      vars:
        incremental_lookback_hours: 12  # Prod uses hourly updates
```

### Choosing the Right Time Unit

#### Days (Most Common)
| Days | Speed | Cost | Late Data Coverage | Use Case |
|------|-------|------|-------------------|----------|
| **1** | ⚡⚡⚡ Fastest | 💰 Cheapest | ⚠️ Minimal | Daily dashboards, no conversions |
| **2** | ⚡⚡ Fast | 💰💰 Low | ⚠️ Basic | Standard campaigns |
| **3** | ⚡ Good | 💰💰💰 Medium | ✅ Good | **Recommended default** |
| **5** | 🐢 Slower | 💰💰💰💰 Higher | ✅✅ Better | Conversion lag |
| **7** | 🐢🐢 Slow | 💰💰💰💰💰 High | ✅✅✅ Best | Long conversion windows |

#### Hours (Real-time)
| Hours | Speed | Cost | Update Frequency | Use Case |
|-------|-------|------|------------------|----------|
| **1** | ⚡⚡⚡ Very Fast | 💰 Very Low | Every hour | Real-time monitoring |
| **6** | ⚡⚡ Fast | 💰💰 Low | 4x per day | Frequent updates |
| **12** | ⚡ Good | 💰💰💰 Medium | 2x per day | **Recommended for hourly** |
| **24** | 🐢 Slower | 💰💰💰💰 Higher | Daily | Same as 1 day |

#### Minutes (Near Real-time)
| Minutes | Speed | Cost | Update Frequency | Use Case |
|---------|-------|------|------------------|----------|
| **5** | ⚡⚡⚡ Instant | 💰 Minimal | Every 5 min | Live dashboards |
| **15** | ⚡⚡ Very Fast | 💰💰 Very Low | Every 15 min | Near real-time |
| **30** | ⚡ Fast | 💰💰💰 Low | Every 30 min | **Recommended for minutes** |
| **60** | 🐢 Slower | 💰💰💰💰 Medium | Hourly | Same as 1 hour |

### Recommendations by Data Type

```yaml
vars:
  # Standard Daily Processing (Default)
  incremental_lookback_days: 3
  
  # Hourly Real-time Processing
  # incremental_lookback_hours: 12
  
  # Near Real-time Processing (Advanced)
  # incremental_lookback_minutes: 30
```

### Real-World Scenarios

#### Scenario 1: Standard Daily Batch (Default)
```yaml
# Balance speed, cost, and data quality
vars:
  incremental_lookback_days: 3
```
**When to use:** 
- Standard daily batch processing
- Dashboard updates once per day
- Most production use cases

**Schedule:** Once daily (e.g., 6 AM)

#### Scenario 2: Hourly Real-time Monitoring
```yaml
# Optimize for near-real-time updates
vars:
  incremental_lookback_hours: 12
```
**When to use:**
- Real-time performance monitoring
- Dashboards updated multiple times per day
- Active campaign optimization

**Schedule:** Every hour or every 6 hours

#### Scenario 3: Near Real-time Dashboard
```yaml
# Ultra-fast updates for live monitoring
vars:
  incremental_lookback_minutes: 30
```
**When to use:**
- Live campaign monitoring
- High-frequency trading/bidding
- Critical real-time alerts

**Schedule:** Every 5-15 minutes

#### Scenario 4: Long Conversion Windows
```yaml
# Optimize for data completeness
vars:
  incremental_lookback_days: 7
```
**When to use:**
- Lead generation campaigns
- B2B with long sales cycles
- View-through conversions important

**Schedule:** Once daily

#### Scenario 2: Conversion Tracking (Default)
```yaml
# Balance speed, cost, and data quality
vars:
  incremental_lookback_days: 3
```
**When to use:**
- Standard conversion tracking
- 1-2 day conversion window
- Most use cases

#### Scenario 3: Long Conversion Windows
```yaml
# Optimize for data completeness
vars:
  incremental_lookback_days: 7
```
**When to use:**
- Lead generation campaigns
- B2B with long sales cycles
- View-through conversions important

#### Scenario 4: Data Quality Issues
```bash
# One-time backfill
dbt run --models fct_campaign_performance --vars '{"incremental_lookback_days": 30}'
```
**When to use:**
- After data source issues
- Fixing historical data
- One-time correction

## 🎯 Testing Different Values

### A/B Test Approach
```bash
# Test 1: Current setting (3 days)
dbt run --models fct_campaign_performance
# Check: Query execution time and cost in logs

# Test 2: Shorter window (2 days)
dbt run --models fct_campaign_performance --vars '{"incremental_lookback_days": 2}' --full-refresh
# Check: Time and cost difference

# Test 3: Longer window (5 days)
dbt run --models fct_campaign_performance --vars '{"incremental_lookback_days": 5}' --full-refresh
# Check: Time and cost difference

# Compare results and choose optimal value
```

### Validation Query
```sql
-- Check if any conversions arrived late
SELECT 
    stat_date,
    COUNT(*) as records,
    SUM(conversions) as total_conversions,
    MAX(last_synced_at) as last_update
FROM {{ ref('fct_campaign_performance') }}
WHERE stat_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY stat_date
ORDER BY stat_date DESC;

-- Look for conversions being updated on older dates
```

## 📊 Impact Analysis

### Cost Calculation
```
Daily BigQuery Cost = Base Query Cost × Lookback Days

Example:
- 1 day lookback: $0.10 per run
- 3 days lookback: $0.30 per run (default)
- 7 days lookback: $0.70 per run

Monthly cost (30 runs):
- 1 day: $3/month
- 3 days: $9/month ← Recommended
- 7 days: $21/month
```

### Time Calculation
```
Execution Time = Base Time × Lookback Days

Example with 100 campaigns:
- 1 day: ~20 seconds
- 3 days: ~60 seconds ← Recommended
- 7 days: ~140 seconds
```

## 🔍 Monitoring

### Check Current Setting
```bash
# View compiled SQL to see actual value
dbt compile --models fct_campaign_performance
cat target/compiled/google_ads_analytics/models/mart/fct_campaign_performance.sql
```

### Log Analysis
```bash
# Check query performance
grep "incremental_lookback_days" logs/dbt.log

# View bytes processed
grep "Bytes Processed" logs/dbt.log
```

### Alert Thresholds
```yaml
# Set alerts when:
# - Execution time > 5 minutes (lookback too large)
# - Missing conversions (lookback too small)
# - BigQuery cost > budget (lookback too large)
```

## 🚨 Troubleshooting

### Issue: Missing Recent Data
**Symptom:** Yesterday's conversions not appearing

**Solution:**
```yaml
# Increase lookback window
vars:
  incremental_lookback_days: 5  # or 7
```

### Issue: High BigQuery Costs
**Symptom:** Unexpected query costs

**Solution:**
```yaml
# Decrease lookback window
vars:
  incremental_lookback_days: 2  # or 1
```

Or run less frequently:
```bash
# Instead of hourly, run 2x per day
0 6,18 * * * dbt run --models fct_*
```

### Issue: Slow Execution
**Symptom:** dbt run takes too long

**Solution:**
```yaml
# Reduce lookback
vars:
  incremental_lookback_days: 2
```

Or parallelize:
```bash
# Run models in parallel
dbt run --models fct_* --threads 4
```

## 📚 Advanced Configurations

### Per-Model Lookback (Advanced)
```yaml
# dbt_project.yml
vars:
  # Default for all models
  incremental_lookback_days: 3
  
  # Override for specific model types
  campaign_lookback_days: 3
  keyword_lookback_days: 7
  search_term_lookback_days: 5
```

Then in model:
```sql
where stat_date >= date_sub(current_date(), 
    interval {{ var('keyword_lookback_days', var('incremental_lookback_days', 3)) }} day)
```

### Dynamic Lookback Based on Day of Week
```sql
-- models/macros/get_lookback_days.sql
{% macro get_lookback_days() %}
    {% set today = modules.datetime.date.today() %}
    {% set day_of_week = today.weekday() %}
    
    {# Monday (0) = process weekend data = 7 days #}
    {% if day_of_week == 0 %}
        {{ return(7) }}
    {% else %}
        {{ return(var('incremental_lookback_days', 3)) }}
    {% endif %}
{% endmacro %}
```

## 📖 Summary

### Quick Reference
```yaml
# dbt_project.yml - Main configuration
vars:
  incremental_lookback_days: 3  # ← Change this value
```

### Common Commands
```bash
# Use configured value (3 days)
dbt run --models fct_*

# Override with 5 days
dbt run --models fct_* --vars '{"incremental_lookback_days": 5}'

# Override with 1 day (fast)
dbt run --models fct_* --vars '{"incremental_lookback_days": 1}'

# Full refresh (ignore incremental)
dbt run --models fct_* --full-refresh
```

### Best Practice
✅ Start with **3 days** (default)  
✅ Monitor data quality and costs  
✅ Adjust based on your conversion windows  
✅ Use command-line override for testing  
✅ Document any changes in team wiki
