# 📌 Quick Reference Card

## ⚙️ Change Incremental Lookback Window

### Method 1: Permanent Change (dbt_project.yml)

**Option A: Days (Default)**
```yaml
# dbt_project.yml
vars:
  incremental_lookback_days: 3  # Last 3 days
```

**Option B: Hours (Real-time)**
```yaml
# dbt_project.yml
vars:
  # incremental_lookback_days: 3     # Comment out
  incremental_lookback_hours: 12     # Last 12 hours
```

**Option C: Minutes (Near Real-time)**
```yaml
# dbt_project.yml
vars:
  # incremental_lookback_days: 3       # Comment out
  # incremental_lookback_hours: 12     # Comment out
  incremental_lookback_minutes: 30     # Last 30 minutes
```

### Method 2: One-Time Override (Command Line)

**Days:**
```bash
# Run with 7 days
dbt run --models fct_* --vars '{"incremental_lookback_days": 7}'
```

**Hours:**
```bash
# Run with 24 hours
dbt run --models fct_* --vars '{"incremental_lookback_hours": 24}'

# Run with 6 hours
dbt run --models fct_* --vars '{"incremental_lookback_hours": 6}'
```

**Minutes:**
```bash
# Run with 60 minutes
dbt run --models fct_* --vars '{"incremental_lookback_minutes": 60}'

# Run with 15 minutes
dbt run --models fct_* --vars '{"incremental_lookback_minutes": 15}'
```

## 🎯 Choosing the Right Value

### Days (Most Common)
| Days | Speed | Cost | Use When |
|------|-------|------|----------|
| **1** | ⚡⚡⚡ | 💰 | Daily batch, no conversions |
| **3** | ⚡ | 💰💰💰 | **Default - Most use cases** |
| **7** | 🐢 | 💰💰💰💰💰 | Long conversion windows |

### Hours (Real-time)
| Hours | Speed | Cost | Use When |
|-------|-------|------|----------|
| **1** | ⚡⚡⚡ | 💰 | Every hour updates |
| **6** | ⚡⚡ | 💰💰 | 4x daily updates |
| **12** | ⚡ | 💰💰💰 | **Recommended for hourly** |
| **24** | 🐢 | 💰💰💰💰 | Same as 1 day |

### Minutes (Near Real-time)
| Minutes | Speed | Cost | Use When |
|---------|-------|------|----------|
| **5** | ⚡⚡⚡ | 💰 | Live dashboards |
| **15** | ⚡⚡ | 💰💰 | Near real-time |
| **30** | ⚡ | 💰💰💰 | **Recommended for minutes** |

## 🚀 Common Commands

```bash
# Daily run (uses configured value)
dbt run

# Run only fact tables
dbt run --models fct_*

# --- DAYS ---
# Run with custom days (one-time)
dbt run --models fct_* --vars '{"incremental_lookback_days": 5}'

# --- HOURS ---
# Run with 12 hours lookback
dbt run --models fct_* --vars '{"incremental_lookback_hours": 12}'

# Run with 6 hours (faster, for hourly updates)
dbt run --models fct_* --vars '{"incremental_lookback_hours": 6}'

# --- MINUTES ---
# Run with 30 minutes lookback
dbt run --models fct_* --vars '{"incremental_lookback_minutes": 30}'

# Run with 15 minutes (very fast, near real-time)
dbt run --models fct_* --vars '{"incremental_lookback_minutes": 15}'

# Full refresh (reprocess all history)
dbt run --models fct_* --full-refresh

# Run and test
dbt build --models mart.*
```

## 📊 Quick Stats

### Days (Default)
**3 Days:**
- ⚡ Time: ~60 seconds
- 💰 Cost: ~$0.30/run
- 📅 Data: Last 3 days
- 🕐 Schedule: Once daily

**1 Day (Fast):**
- ⚡ Time: ~20 seconds
- 💰 Cost: ~$0.10/run
- 📅 Data: Yesterday only
- ⚠️ May miss late conversions

**7 Days (Safe):**
- ⚡ Time: ~140 seconds
- 💰 Cost: ~$0.70/run
- 📅 Data: Last 7 days
- ✅ Captures all late data

### Hours (Real-time)
**12 Hours:**
- ⚡ Time: ~40 seconds
- 💰 Cost: ~$0.20/run
- 📅 Data: Last 12 hours
- 🕐 Schedule: Every 6-12 hours

**6 Hours:**
- ⚡ Time: ~20 seconds
- 💰 Cost: ~$0.10/run
- 📅 Data: Last 6 hours
- 🕐 Schedule: Every 3-6 hours

**1 Hour:**
- ⚡ Time: ~5 seconds
- 💰 Cost: ~$0.02/run
- 📅 Data: Last hour
- 🕐 Schedule: Every hour

### Minutes (Near Real-time)
**30 Minutes:**
- ⚡ Time: ~3 seconds
- 💰 Cost: ~$0.01/run
- 📅 Data: Last 30 min
- 🕐 Schedule: Every 15-30 min

**15 Minutes:**
- ⚡ Time: ~2 seconds
- 💰 Cost: ~$0.005/run
- 📅 Data: Last 15 min
- 🕐 Schedule: Every 5-15 min

## 🔍 Validation

```sql
-- Check latest data
SELECT MAX(stat_date) FROM {{ ref('fct_campaign_performance') }};

-- Check for duplicates (should return 0 rows)
SELECT 
    account_id, campaign_id, stat_date, COUNT(*)
FROM {{ ref('fct_campaign_performance') }}
GROUP BY 1,2,3
HAVING COUNT(*) > 1;
```

## 📚 Documentation

- **Full Guide**: [CONFIGURATION.md](CONFIGURATION.md)
- **Incremental Details**: [models/google_ads/mart/INCREMENTAL_GUIDE.md](models/google_ads/mart/INCREMENTAL_GUIDE.md)
- **Model Overview**: [models/google_ads/mart/README.md](models/google_ads/mart/README.md)

## ⚡ Pro Tips

1. **Start with 3 days** (default)
2. **Monitor** data quality and BigQuery costs
3. **Increase** if you see missing conversions
4. **Decrease** if costs are too high
5. **Test** different values on weekends
6. **Document** your choice for team

## 🚨 When to Full Refresh

```bash
# Run full refresh when:
# - Initial setup
# - Schema changes
# - Data quality issues
# - After changing lookback window significantly

dbt run --models fct_* --full-refresh
```

## 💡 Examples

### Standard Daily Processing (Recommended)
```yaml
# dbt_project.yml
vars:
  incremental_lookback_days: 3
```
**Schedule:** Once daily at 6 AM

### Hourly Real-time Updates
```yaml
# dbt_project.yml
vars:
  incremental_lookback_hours: 12
```
**Schedule:** Every hour or every 6 hours

### Near Real-time Live Dashboard
```yaml
# dbt_project.yml
vars:
  incremental_lookback_minutes: 30
```
**Schedule:** Every 15 minutes

### E-commerce (Fast Conversions)
```yaml
vars:
  incremental_lookback_days: 2
```

### B2B Lead Gen (Slow Conversions)
```yaml
vars:
  incremental_lookback_days: 7
```

### Cost-Optimized (Budget Conscious)
```yaml
vars:
  incremental_lookback_hours: 6  # Instead of days
```

### Weekend Catch-Up (Monday Only)
```bash
# Run on Monday with extra lookback
dbt run --models fct_* --vars '{"incremental_lookback_days": 7}'
```

### Intraday Updates (4x per day)
```bash
# Run every 6 hours
*/6 * * * * dbt run --models fct_* --vars '{"incremental_lookback_hours": 6}'
```

---

**Need more help?** See [CONFIGURATION.md](CONFIGURATION.md) for complete guide.
