# Quick Start Checklist

Làm theo các bước sau để kết nối dbt với BigQuery:

## ✅ Checklist

### 1. Cập nhật dbt_project.yml
- [x] Đã cập nhật `name: 'google_ads_analytics'`
- [x] Đã cập nhật `profile: 'google_ads'`
- [x] Đã thêm cấu hình cho staging models

### 2. Tạo profiles.yml
- [ ] Tạo thư mục `~/.dbt/` (hoặc `C:\Users\ADMIN\.dbt\`)
- [ ] Copy `profiles.yml.example` thành `~/.dbt/profiles.yml`
- [ ] Cập nhật `project:` với GCP Project ID của bạn
- [ ] Cập nhật `dataset:` với tên dataset chính
- [ ] Cập nhật `keyfile:` với đường dẫn tới service account JSON

### 3. Tạo Service Account (nếu chưa có)
- [ ] Vào GCP Console → IAM & Admin → Service Accounts
- [ ] Tạo service account mới
- [ ] Grant quyền: BigQuery Data Editor + BigQuery Job User
- [ ] Tạo JSON key và download về
- [ ] Lưu file JSON tại vị trí an toàn

### 4. Cập nhật google_ads_sources.yml
- [ ] Mở `models/staging/google_ads_sources.yml`
- [ ] Thay `YOUR_GCP_PROJECT_ID` bằng Project ID thực tế
- [ ] Thay `google_ads_fivetran` bằng tên dataset thực tế trong BigQuery

### 4.5. Tạo BigQuery Datasets (QUAN TRỌNG!)
Trước khi chạy dbt, cần tạo datasets trong BigQuery:

**Option 1: Qua BigQuery Console**
1. Vào [BigQuery Console](https://console.cloud.google.com/bigquery)
2. Click vào project của bạn
3. Click **"CREATE DATASET"**
4. Tạo dataset với thông tin:
   - Dataset ID: `dbt_dhoang` (hoặc tên user của bạn)
   - Location: **asia-southeast2** (phải khớp với profiles.yml)
   - Click "Create"
5. Lặp lại để tạo thêm: `google_ads_analytics_staging` (nếu cần)

**Option 2: Qua Command Line**
```bash
# Tạo dataset chính cho mart models
bq mk --location=asia-southeast2 --dataset savvy-webbing-480102-t0:dbt_dhoang

# Tạo dataset cho staging (nếu cần)
bq mk --location=asia-southeast2 --dataset savvy-webbing-480102-t0:google_ads_analytics_staging
```

**⚠️ Lưu ý về Location:**
- Location trong BigQuery dataset PHẢI khớp với location trong `profiles.yml`
- Nếu source data ở `asia-southeast2`, tất cả datasets phải dùng cùng location
- Không thể query cross-region trong BigQuery

### 5. Test kết nối
```bash
dbt debug
```

### 6. Chạy models
```bash
# Test kết nối
dbt debug

# Chạy staging models (15 models)
dbt run --select staging

# Chạy mart models (11 models: 5 fact tables + 6 report tables)
dbt run --select mart

# Hoặc chạy toàn bộ project (staging + mart)
dbt run

# Chạy models cụ thể
dbt run --select fct_campaign_performance
dbt run --select rpt_budget_gauge
```

### 7. Kiểm tra kết quả
```bash
# Compile và kiểm tra SQL
dbt compile

# Chạy tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

## 📊 Models Overview

### Staging Layer (15 models)
- `stg_google_ads__account_history`
- `stg_google_ads__account_stats`
- `stg_google_ads__campaign_history`
- `stg_google_ads__campaign_stats`
- `stg_google_ads__campaign_budget_history`
- `stg_google_ads__ad_group_history`
- `stg_google_ads__ad_group_stats`
- `stg_google_ads__ad_history`
- `stg_google_ads__ad_stats`
- `stg_google_ads__keyword_stats`
- `stg_google_ads__search_term_stats`
- And more...

### Mart Layer (11 models)
**Fact Tables (5):**
- `fct_campaign_performance` - Daily campaign metrics with budget info
- `fct_ad_group_performance` - Daily ad group metrics
- `fct_ad_performance` - Daily ad metrics
- `fct_keyword_performance` - Daily keyword metrics
- `fct_search_term_performance` - Daily search term metrics

**Report Tables (6):**
- `rpt_campaign_summary` - Campaign aggregation with budget tracking
- `rpt_ad_group_summary` - Ad group aggregation
- `rpt_device_performance` - Performance by device
- `rpt_monthly_performance` - Monthly trends
- `rpt_budget_tracking` ⭐ - Detailed budget tracking with pacing
- `rpt_budget_gauge` ⭐ - Gauge chart ready metrics for budget monitoring

## 🎯 Quick Test Queries

```sql
-- Test campaign performance with budget
SELECT 
    campaign_name,
    stat_date,
    cost,
    daily_budget,
    daily_budget_spend_pct,
    conversions
FROM `your-project.google_ads_analytics.fct_campaign_performance`
WHERE stat_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
ORDER BY stat_date DESC, cost DESC
LIMIT 10;

-- Test budget gauge (for dashboard)
SELECT 
    metric_level,
    metric_name,
    total_budget,
    total_spent,
    spend_percentage,
    gauge_color,
    status
FROM `your-project.google_ads_analytics.rpt_budget_gauge`
WHERE metric_level = 'CAMPAIGN'
ORDER BY spend_percentage DESC;
```

## 📝 Thông tin cần thiết

Bạn cần chuẩn bị các thông tin sau:

| Thông tin | Ví dụ | Tìm ở đâu |
|-----------|-------|-----------|
| GCP Project ID | `my-project-123456` | BigQuery Console, góc trên bên trái |
| Dataset Name | `google_ads_fivetran` | BigQuery Console, panel bên trái |
| Service Account Key | `service-account.json` | GCP Console → IAM & Admin → Service Accounts |
| BigQuery Location | `US` hoặc `asia-southeast1` | BigQuery Console → Dataset Details |

## 🔗 Tài liệu tham khảo

- [SETUP_GUIDE.md](./SETUP_GUIDE.md) - Hướng dẫn chi tiết đầy đủ
- [dbt BigQuery Setup](https://docs.getdbt.com/reference/warehouse-setups/bigquery-setup)
- [profiles.yml.example](./profiles.yml.example) - Template cấu hình
- [Mart Layer README](./models/mart/README.md) - Hướng dẫn sử dụng mart models

## 🚨 Troubleshooting

### Error: "Dataset was not found in location"
```
Database Error: Not found: Dataset savvy-webbing-480102-t0:dbt_dhoang was not found in location asia-southeast2
```

**Nguyên nhân:** Dataset chưa được tạo trong BigQuery hoặc location không khớp.

**Giải pháp:**
1. **Tạo dataset trước khi chạy dbt:**
   ```bash
   bq mk --location=asia-southeast2 --dataset savvy-webbing-480102-t0:dbt_dhoang
   ```

2. **Kiểm tra location trong `profiles.yml` khớp với BigQuery:**
   ```yaml
   outputs:
     dev:
       location: asia-southeast2  # Phải khớp với location của source data
   ```

3. **Kiểm tra tên dataset trong `dbt_project.yml`:**
   ```yaml
   models:
     google_ads_analytics:
       staging:
         +schema: staging
       mart:
         +schema: mart
   ```

4. **Verify dataset đã tạo:**
   ```bash
   bq ls --project_id=savvy-webbing-480102-t0
   ```

### Error: "Credentials do not authorize"
- Kiểm tra service account có đủ quyền: BigQuery Data Editor + BigQuery Job User
- Kiểm tra đường dẫn tới keyfile trong `profiles.yml`
- Chạy `gcloud auth application-default login` nếu dùng OAuth

### Error: "Relation not found" trong staging models
- Kiểm tra source data đã được sync từ Fivetran chưa
- Verify tên dataset trong `google_ads_sources.yml` đúng
- Chạy: `dbt source freshness` để check

### Error: Models chạy chậm hoặc timeout
- Tăng `timeout_seconds` trong `profiles.yml` (mặc định 300s)
- Giảm số `threads` nếu hit rate limits
- Kiểm tra query complexity trong các models

### Không thấy tables sau khi chạy dbt run
- Kiểm tra BigQuery Console xem tables có được tạo không
- Verify schema naming: `<project>.<dataset>.<schema>_<model_name>`
- Ví dụ: `savvy-webbing-480102-t0.dbt_dhoang.mart_fct_campaign_performance`

## 💡 Tips

- Luôn chạy `dbt debug` trước khi chạy models
- Dùng `dbt run --select +model_name` để chạy model và tất cả dependencies
- Dùng `dbt run --select model_name+` để chạy model và tất cả downstream models
- Set up `.gitignore` để không commit `profiles.yml` và service account keys
- Sử dụng `dbt run --full-refresh` để rebuild incremental models
