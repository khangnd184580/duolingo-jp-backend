# Database scripts (khớp MyWebApiApp / EF)

Schema học tập dùng **`Level`**, **`Topic`**, **`Lessons`** (`TopicId`, `LessonName`, `BaseXP`), **`Questions`** (`Content`, `OrderIndex`), **`QuestionOptions`**, **`LessonAttempts`**, **`UserAnswers`** — đúng với code C#, **không** dùng `Units` / `Nodes`.

## Chạy nhanh

Từ thư mục `Scripts` (để `MasterSetup.sql` resolve `:r` đúng):

```powershell
cd path\to\MyWebApiApp\Scripts
sqlcmd -S YOUR_SERVER -d DuolingoJP -E -i MasterSetup.sql
```

Hoặc:

```powershell
.\RunSetup.ps1 -ServerInstance "YOUR_SERVER" -Database "DuolingoJP"
```

## Thứ tự file

| File | Mục đích |
|------|-----------|
| **FixDatabaseForCurrentBackend.sql** | Thêm `UserItems.IsEquipped`, đổi PK `UserItemId` → `Id` (khớp EF + Shop). |
| **SeedLearningContent_EfCompatible.sql** | Seed Level, Topic, Lessons, Questions, Options (idempotent). |
| **SeedShopItems.sql** | Seed 15 dòng `Items`. |
| **MasterSetup.sql** | Gọi lần lượt 3 file trên. |

## Đã ngừng dùng (chỉ in thông báo)

- `CreateLessonContentTables.sql`, `SeedAllData.sql`, `InsertSimple.sql`, `InsertSimpleWithUserId.sql`, `SeedLessonContent.sql` — schema cũ (Units/Nodes hoặc cột `QuestionText`…), **không** khớp backend hiện tại.

## Schema & migrations

Tạo/cập nhật bảng từ code: `dotnet ef database update` (trong thư mục project API). Các file `.sql` ở đây chủ yếu để **bổ sung cột lệch** (Fix…) và **seed dữ liệu**.

## Kiểm tra nhanh

```sql
SELECT COUNT(*) FROM [Level];
SELECT COUNT(*) FROM [Topic];
SELECT COUNT(*) FROM Lessons;
SELECT COUNT(*) FROM Questions;
SELECT COUNT(*) FROM Items WHERE IsActive = 1;
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'UserItems';
```

`GetUserId.sql` vẫn dùng được khi cần xem `AspNetUsers.Id` (GUID string).
