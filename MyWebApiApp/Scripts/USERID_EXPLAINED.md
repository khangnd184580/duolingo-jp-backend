# ⚠️ QUAN TRỌNG: UserId và Foreign Keys

## Vấn đề

Trong dự án này có 2 loại `UserId`:

### 1. **UserId kiểu `string`** (ĐÚNG)
Các bảng này có FK tới `AspNetUsers.Id` (GUID string):
- ✅ `UserLessonProgress.UserId` → `string`
- ✅ `Transaction.UserId` → `string`
- ✅ `UserItem.UserId` → `string`
- ✅ `UserAnswer.UserId` → `string`
- ✅ `LessonAttempt.UserId` → `string`

### 2. **UserId kiểu `int`** (DUMMY - Không có FK)
- ❌ `Node.UserId` → `int` (không có foreign key constraint)

## Giải pháp Insert Data

### **Cách 1: Dùng UserId thật (Cho bảng cần FK)** ⭐

```sql
-- Bước 1: Tạo user qua API Register
-- Bước 2: Lấy UserId
SELECT Id, UserName FROM AspNetUsers;
-- Result: abc123-def456-ghi789...

-- Bước 3: Dùng UserId này trong script
DECLARE @UserId NVARCHAR(450) = 'abc123-def456-ghi789...';

-- Insert với UserId thật
INSERT INTO UserLessonProgress (UserId, NodeId, Status, CurrentLessonIndex)
VALUES (@UserId, 1, 'Unlocked', 0);
```

### **Cách 2: Dùng số dummy (Cho Node.UserId)**

```sql
-- Node.UserId là dummy, không có FK constraint
INSERT INTO Nodes (UnitId, UserId, NodeType, Position)
VALUES (1, 1, 'lesson', 1);  -- UserId = 1 (dummy number)
```

## Script Files

| File | Mục đích | UserId type |
|------|----------|-------------|
| `GetUserId.sql` | Lấy UserId thật | string |
| `InsertSimpleWithUserId.sql` | Insert với UserId thật | string |
| `InsertSimple.sql` | Insert với dummy UserId | int (cho Node) |

## Khi nào dùng file nào?

### Dùng `InsertSimple.sql` nếu:
- Chỉ test Lessons/Questions (không cần User data)
- Nodes dùng dummy UserId = 1
- Không insert vào `UserLessonProgress`, `Transaction`, `UserItem`

### Dùng `InsertSimpleWithUserId.sql` nếu:
- Cần insert progress của user
- Cần insert transactions
- Cần data có FK tới `AspNetUsers`

## Quick Start

### Option A: Chỉ test Lesson Content (Fast)

```sql
-- Run once
:r CreateLessonContentTables.sql
:r InsertSimple.sql

-- Test với API
GET /api/lesson-content/1
```

### Option B: Full setup với User data

```bash
# 1. Register user qua API
POST /api/account/register

# 2. Get UserId
:r GetUserId.sql

# 3. Update script với UserId
# Edit InsertSimpleWithUserId.sql line 7

# 4. Run script
:r InsertSimpleWithUserId.sql
```

## ⚡ TL;DR (Too Long; Didn't Read)

```sql
-- Nhanh nhất: Chỉ cần chạy này
:r CreateLessonContentTables.sql
:r InsertSimple.sql

-- Xong! Test được rồi
GET /api/lesson-content/1
```

Sau đó register user qua API để test đầy đủ workflow.
