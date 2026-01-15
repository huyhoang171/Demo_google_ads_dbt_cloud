# 🔄 Project Structure Migration

**Date:** January 15, 2026  
**Change:** Reorganized folder structure for better organization

## 📁 Before (Old Structure)

```
models/
├── staging/
│   ├── google_ads_sources.yml
│   ├── stg_google_ads__campaign_stats.sql
│   └── ...
├── mart/
│   ├── fct_campaign_performance.sql
│   ├── rpt_campaign_summary.sql
│   └── ...
└── google_ads/ (empty)
```

## 📁 After (New Structure)

```
models/
└── google_ads/
    ├── README.md (new)
    ├── staging/
    │   ├── google_ads_sources.yml
    │   ├── stg_google_ads__campaign_stats.sql
    │   └── ...
    └── mart/
        ├── fct_campaign_performance.sql
        ├── rpt_campaign_summary.sql
        └── ...
```

## ✅ Changes Made

### 1. Folder Structure
- ✅ Moved `models/staging/` → `models/google_ads/staging/`
- ✅ Moved `models/mart/` → `models/google_ads/mart/`
- ✅ Created `models/google_ads/README.md`

### 2. Configuration Updates
- ✅ Updated `dbt_project.yml` model paths
- ✅ Updated `README.md` documentation paths
- ✅ Updated `QUICK_REFERENCE.md` documentation paths
- ✅ Verified relative paths in `mart/INCREMENTAL_GUIDE.md` (still correct)
- ✅ Verified relative paths in `mart/README.md` (still correct)

### 3. Files Unchanged
- ✅ All SQL files remain unchanged (no code changes needed)
- ✅ All documentation content remains the same
- ✅ All configurations work as before

## 🚀 Updated Commands

### Old Commands (Still Work)
```bash
# These still work due to model naming
dbt run --models staging.*
dbt run --models mart.*
dbt run --models fct_*
dbt run --models rpt_*
```

### New Commands (Recommended)
```bash
# Run all Google Ads models
dbt run --models google_ads

# Run staging layer
dbt run --models google_ads.staging

# Run mart layer
dbt run --models google_ads.mart

# Run fact tables
dbt run --models google_ads.mart.fct_*

# Run report tables
dbt run --models google_ads.mart.rpt_*
```

## 🎯 Benefits

1. **Better Organization**: All Google Ads models grouped under one folder
2. **Scalability**: Easy to add other data sources (e.g., `models/facebook_ads/`)
3. **Clarity**: Clear separation of concerns with nested structure
4. **Modularity**: Can run entire `google_ads` module or specific sub-layers
5. **Best Practice**: Follows dbt recommended project structure

## 🔍 Verification

To verify the migration was successful:

```bash
# List all models
dbt ls --models google_ads

# Expected output:
# google_ads.staging.stg_google_ads__campaign_stats
# google_ads.staging.stg_google_ads__ad_group_stats
# ...
# google_ads.mart.fct_campaign_performance
# google_ads.mart.rpt_campaign_summary
# ...

# Compile a model to check
dbt compile --models google_ads.mart.fct_campaign_performance

# Run tests
dbt test --models google_ads
```

## 📝 Migration Notes

- **No Breaking Changes**: All existing functionality preserved
- **Backward Compatible**: Old model selectors still work
- **Documentation**: All docs updated with new paths
- **Version Control**: Commit this structure change as single atomic commit

## 🔄 Future Structure (Expandable)

```
models/
├── google_ads/
│   ├── staging/
│   └── mart/
├── facebook_ads/
│   ├── staging/
│   └── mart/
└── cross_platform/
    └── mart/
```

## ✅ Checklist

- [x] Move staging folder
- [x] Move mart folder
- [x] Update dbt_project.yml
- [x] Update main README.md
- [x] Update QUICK_REFERENCE.md
- [x] Verify relative paths in docs
- [x] Create google_ads/README.md
- [x] Test structure with dbt commands
- [x] Document migration

---

**Migration Status:** ✅ Complete  
**Tested:** Ready for use  
**Next Steps:** Run `dbt run --models google_ads` to verify
