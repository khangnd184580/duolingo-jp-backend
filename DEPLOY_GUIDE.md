# 🚀 HƯỚNG DẪN DEPLOY BACKEND LÊN RENDER.COM

Backend: ASP.NET Core 10.0 + PostgreSQL  
Frontend: Flutter (Android APK)

---

## 📋 BƯỚC 1: TẠO POSTGRESQL DATABASE TRÊN RENDER

### 1.1. Đăng nhập Render
1. Truy cập: https://dashboard.render.com
2. Đăng nhập bằng **GitHub** (hoặc Email nếu đã đăng ký)

### 1.2. Tạo Database
1. Nhấn nút **"New +"** ở góc trên bên phải
2. Chọn **"PostgreSQL"**
3. Điền thông tin:
   - **Name**: `duolingo-jp-db`
   - **Database**: `duolingo_jp`
   - **User**: `duolingo_admin` (tùy chọn)
   - **Region**: Chọn **Singapore** (gần Việt Nam nhất)
   - **PostgreSQL Version**: Để mặc định (Latest)
   - **Plan**: Chọn **Free** (0$/tháng)

4. Nhấn **"Create Database"**
5. Đợi 1-2 phút để Render khởi tạo database

### 1.3. Lấy Connection String
1. Sau khi database tạo xong, kéo xuống phần **"Connections"**
2. **QUAN TRỌNG**: Copy **Internal Database URL** (KHÔNG phải External)
   - URL có dạng: `postgresql://duolingo_admin:xxxxx@dpg-xxxxx-a.singapore-postgres.render.com/duolingo_jp`
3. **LƯU URL NÀY LẠI** - Sẽ dùng ở bước sau!

---

## 📦 BƯỚC 2: DEPLOY BACKEND WEB SERVICE

### 2.1. Tạo Web Service
1. Quay lại Dashboard Render: https://dashboard.render.com
2. Nhấn **"New +"** → Chọn **"Web Service"**
3. Chọn **"Build and deploy from a Git repository"** → Nhấn **Next**

### 2.2. Connect GitHub Repository
1. Nếu lần đầu: Nhấn **"Connect GitHub"** → Authorize Render
2. Tìm và chọn repository: **`duolingo-jp-backend`**
3. Nhấn **"Connect"**

### 2.3. Cấu hình Web Service
Điền thông tin như sau:

**Basic Information:**
- **Name**: `duolingo-jp-api` (hoặc tên bạn thích)
- **Region**: **Singapore** (giống với database)
- **Branch**: `main`
- **Root Directory**: Để trống (`.`)
- **Runtime**: Chọn **Docker**

**Build & Deploy:**
- **Dockerfile Path**: `Dockerfile` (mặc định)

**Plan:**
- Chọn **Free** (0$/tháng)

### 2.4. Environment Variables (QUAN TRỌNG!)
Kéo xuống phần **"Environment Variables"** và thêm các biến sau:

| Key | Value |
|-----|-------|
| `ConnectionStrings__DefaultConnection` | [Paste URL PostgreSQL từ Bước 1.3] |
| `UsePostgreSQL` | `true` |
| `ASPNETCORE_ENVIRONMENT` | `Production` |
| `JWT__SigningKey` | `dhq8d2oi28ye9ykadoih18e2dj20e1-e1he8h289ehfhiady28uy29eqh8ed91` |
| `JWT__Issuer` | `https://duolingo-jp-api.onrender.com` |
| `JWT__Audience` | `https://duolingo-jp-api.onrender.com` |

**Lưu ý**: 
- Thay `duolingo-jp-api` trong URL bằng **Name** bạn đặt ở trên
- Không có khoảng trắng giữa Key và Value

### 2.5. Deploy
1. Nhấn **"Create Web Service"**
2. Render sẽ bắt đầu build và deploy (mất 5-10 phút)
3. Quan sát logs để theo dõi quá trình:
   - Xanh = Thành công
   - Đỏ = Lỗi (xem logs để debug)

### 2.6. Kiểm tra Backend đã chạy
Sau khi deploy xong (status hiển thị **"Live"**):
1. Copy URL của backend (dạng: `https://duolingo-jp-api.onrender.com`)
2. Mở trình duyệt và truy cập: `https://duolingo-jp-api.onrender.com/swagger`
3. Nếu thấy giao diện Swagger UI → **THÀNH CÔNG!** ✅

---

## 🗄️ BƯỚC 3: TẠO BẢNG DATABASE (MIGRATION)

Backend đã chạy nhưng database còn TRỐNG. Cần chạy migration để tạo bảng.

### Cách 1: Dùng EF Core từ máy local (Khuyên dùng)

#### 3.1. Cài EF Core Tools (nếu chưa có)
```powershell
dotnet tool install --global dotnet-ef
```

#### 3.2. Cập nhật Connection String tạm thời
Mở file: `MyWebApiApp/appsettings.json`

Sửa `ConnectionStrings:DefaultConnection` thành **Internal Database URL** từ Render

**VÍ DỤ:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=dpg-xxxxx-a.singapore-postgres.render.com;Database=duolingo_jp;Username=duolingo_admin;Password=xxxxx;SSL Mode=Require;Trust Server Certificate=true"
  },
  "UsePostgreSQL": true
}
```

#### 3.3. Chạy Migration
```powershell
cd d:\MyProjects\SWD392\Flutter_And_Frontend\backend\DuolingoStyleJP\MyWebApiApp
dotnet ef database update
```

Nếu thành công, bạn sẽ thấy:
```
Done.
```

#### 3.4. Seed dữ liệu (Tùy chọn)
Chạy các script SQL trong thư mục `Scripts/` để thêm dữ liệu mẫu:

1. Truy cập Render Dashboard → Database → Tab **"Console"**
2. Paste nội dung file SQL (ví dụ: `SeedAllData.sql`)
3. Nhấn **"Execute"**

---

## 📱 BƯỚC 4: CẬP NHẬT FLUTTER APP

### 4.1. Sửa API Config
Mở file: `flutter_duolingo/lib/config/api_config.dart`

Sửa `baseUrl` thành URL backend trên Render:

```dart
class ApiConfig {
  // URL backend production trên Render
  static const String baseUrl = 'https://duolingo-jp-api.onrender.com';
  
  // Các endpoint khác giữ nguyên...
}
```

**Lưu ý**: Thay `duolingo-jp-api` bằng tên backend bạn đặt ở Bước 2.3

### 4.2. Build APK
```powershell
cd d:\MyProjects\SWD392\Flutter_And_Frontend\flutter_duolingo
flutter clean
flutter pub get
flutter build apk --release
```

File APK sẽ nằm ở:
```
flutter_duolingo\build\app\outputs\flutter-apk\app-release.apk
```

### 4.3. Cài APK lên điện thoại
1. Copy file `app-release.apk` vào điện thoại
2. Mở file và cài đặt
3. Mở app → Test chức năng đăng nhập/đăng ký

---

## ✅ HOÀN TẤT!

App của bạn giờ đã:
- ✅ Backend chạy trên Render.com (miễn phí)
- ✅ Database PostgreSQL trên cloud
- ✅ Flutter app kết nối tới backend production
- ✅ APK có thể cài trên bất kỳ điện thoại Android nào

---

## ⚠️ LƯU Ý QUAN TRỌNG

### 1. Free Tier Limitations
- **Render Free Plan**: Backend sẽ "ngủ" sau 15 phút không hoạt động
- Lần đầu mở app sau khi backend "ngủ" sẽ mất 30-60 giây để "đánh thức"
- Database miễn phí có giới hạn 100MB và tự xóa sau 90 ngày

### 2. Bảo mật
- **KHÔNG COMMIT** file `appsettings.Production.json` nếu có thông tin nhạy cảm
- Nên đổi `JWT:SigningKey` thành key phức tạp hơn cho production

### 3. Nâng cấp (Tùy chọn)
Nếu muốn backend không bị "ngủ":
- Upgrade Render plan lên **Starter** ($7/tháng)
- Hoặc dùng cron job ping backend mỗi 10 phút

---

## 🐛 TROUBLESHOOTING

### Lỗi: Backend không build được
- Kiểm tra logs trên Render Dashboard
- Thường do thiếu Environment Variables

### Lỗi: App không kết nối được backend
- Kiểm tra URL trong `api_config.dart` có đúng không
- Kiểm tra backend có status "Live" trên Render không
- Thử truy cập `/swagger` trên trình duyệt

### Lỗi: Database connection failed
- Kiểm tra Connection String có đúng không
- Đảm bảo dùng **Internal Database URL** (không phải External)

---

## 📞 HỖ TRỢ

Nếu gặp vấn đề:
1. Kiểm tra logs trên Render Dashboard
2. Xem logs của Flutter app bằng `flutter logs`
3. Hỏi lại AI hoặc Google với log lỗi cụ thể

---

**Chúc bạn deploy thành công!** 🚀
