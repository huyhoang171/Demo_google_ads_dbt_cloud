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

### 5. Test kết nối
```bash
dbt debug
```

### 6. Chạy models
```bash
dbt run --select staging
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
