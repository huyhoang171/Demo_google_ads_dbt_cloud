# Hướng dẫn cấu hình dbt với BigQuery cho Google Ads Data

## Bước 1: Cập nhật file `dbt_project.yml`

Mở file `dbt_project.yml` và thay đổi:

```yaml
name: 'google_ads_analytics'  # Thay đổi từ 'my_new_project'
profile: 'google_ads'          # Thay đổi từ 'default'
```

Và cập nhật phần models:

```yaml
models:
  google_ads_analytics:
    staging:
      +materialized: view
      +schema: staging
```

## Bước 2: Tạo file `profiles.yml`

> [!IMPORTANT]
> File `profiles.yml` nên được đặt tại `~/.dbt/profiles.yml` (hoặc `C:\Users\ADMIN\.dbt\profiles.yml` trên Windows)

Tạo file với nội dung sau:

```yaml
google_ads:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: YOUR_GCP_PROJECT_ID          # Thay bằng GCP Project ID của bạn
      dataset: google_ads_analytics          # Dataset chính
      threads: 4
      timeout_seconds: 300
      location: US                           # Hoặc asia-southeast1 nếu data ở Singapore
      keyfile: /path/to/service-account.json # Đường dẫn tới service account key
      
      # Hoặc nếu dùng OAuth:
      # method: oauth
      # project: YOUR_GCP_PROJECT_ID
      # dataset: google_ads_analytics
      # threads: 4
      # timeout_seconds: 300
      # location: US
```

## Bước 3: Cập nhật `google_ads_sources.yml`

Mở file `models/staging/google_ads_sources.yml` và cập nhật:

```yaml
sources:
  - name: google_ads
    description: Google Ads data synced via Fivetran
    database: YOUR_GCP_PROJECT_ID        # Thay bằng GCP Project ID
    schema: google_ads_fivetran          # Thay bằng tên schema/dataset thực tế
```

**Cách tìm thông tin:**
1. Mở BigQuery Console
2. Tìm dataset chứa Google Ads data
3. Dataset name chính là giá trị cho `schema`
4. Project ID hiển thị ở đầu trang BigQuery

## Bước 4: Tạo Service Account (nếu chưa có)

### 4.1. Tạo Service Account trên GCP:
1. Vào [GCP Console](https://console.cloud.google.com)
2. Chọn project của bạn
3. Vào **IAM & Admin** → **Service Accounts**
4. Click **Create Service Account**
5. Đặt tên (ví dụ: `dbt-bigquery`)
6. Grant quyền: **BigQuery Data Editor** và **BigQuery Job User**
7. Click **Done**

### 4.2. Tạo Key:
1. Click vào service account vừa tạo
2. Vào tab **Keys**
3. Click **Add Key** → **Create new key**
4. Chọn **JSON**
5. Download file JSON về máy
6. Lưu file tại vị trí an toàn (ví dụ: `C:\Users\ADMIN\.dbt\service-account.json`)

## Bước 5: Test kết nối

Chạy lệnh sau để test:

```bash
dbt debug
```

Nếu thành công, bạn sẽ thấy:
```
Connection test: [OK connection ok]
```

## Bước 6: Chạy staging models

```bash
# Chạy tất cả models
dbt run

# Hoặc chỉ chạy staging models
dbt run --select staging

# Chạy một model cụ thể
dbt run --select stg_google_ads__campaign_stats
```

## Bước 7: Test data

```bash
# Chạy tests
dbt test

# Test một model cụ thể
dbt test --select stg_google_ads__campaign_stats
```

## Cấu trúc thư mục sau khi setup

```
Demo_google_ads_dbt_cloud/
├── dbt_project.yml              # ✅ Đã cập nhật
├── models/
│   └── staging/
│       ├── google_ads_sources.yml  # ✅ Cần cập nhật database & schema
│       ├── stg_google_ads__*.sql   # ✅ Đã tạo 15 models
│       └── README.md
└── ~/.dbt/
    └── profiles.yml             # ⚠️ Cần tạo mới
```

## Troubleshooting

### Lỗi: "Could not find profile"
- Kiểm tra tên profile trong `dbt_project.yml` khớp với `profiles.yml`
- Đảm bảo `profiles.yml` ở đúng vị trí `~/.dbt/`

### Lỗi: "Credentials do not authorize"
- Kiểm tra service account có đủ quyền BigQuery
- Kiểm tra đường dẫn tới keyfile đúng

### Lỗi: "Dataset not found"
- Kiểm tra tên dataset trong `google_ads_sources.yml`
- Kiểm tra project ID đúng

### Lỗi: "Relation not found"
- Kiểm tra tên bảng trong BigQuery
- Đảm bảo data đã được sync từ Fivetran

## Các lệnh dbt hữu ích

```bash
# Compile models (không chạy)
dbt compile

# Xem lineage graph
dbt docs generate
dbt docs serve

# Chạy models theo tag
dbt run --select tag:daily

# Chạy models đã thay đổi
dbt run --select state:modified

# Fresh check
dbt source freshness
```

## Next Steps

Sau khi setup thành công:
1. Tạo thêm staging models cho các bảng còn lại (76 bảng)
2. Tạo intermediate models để join các bảng
3. Tạo mart models cho business logic
4. Setup tests và documentation
5. Schedule dbt runs (dbt Cloud hoặc Airflow)
