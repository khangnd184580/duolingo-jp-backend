# Duolingo-style Japanese Learning App - Backend

Backend API cho ứng dụng học tiếng Nhật phong cách Duolingo.

## 🛠️ Tech Stack

- **Framework**: ASP.NET Core 10.0
- **Database**: SQL Server (local) / PostgreSQL (production)
- **Authentication**: JWT Bearer Token
- **ORM**: Entity Framework Core

## 🚀 Deploy to Production

Xem hướng dẫn chi tiết tại: [DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md)

## 🏃 Run Locally

```bash
cd MyWebApiApp
dotnet restore
dotnet run
```

API sẽ chạy tại: `http://localhost:5196`

Swagger UI: `http://localhost:5196/swagger`

## 📁 Project Structure

```
MyWebApiApp/
├── Controllers/      # API endpoints
├── Models/           # Database models
├── DTOs/             # Data Transfer Objects
├── Services/         # Business logic
├── Repository/       # Data access layer
├── Interfaces/       # Service interfaces
├── Data/             # DbContext
├── Scripts/          # SQL seed scripts
└── Migrations/       # EF Core migrations
```

## 🔑 Environment Variables

```
ConnectionStrings__DefaultConnection=<your-database-url>
UsePostgreSQL=true|false
ASPNETCORE_ENVIRONMENT=Development|Production
JWT__SigningKey=<your-secret-key>
JWT__Issuer=<your-issuer-url>
JWT__Audience=<your-audience-url>
```

## 📱 Frontend

Flutter app repository: (Link to Flutter repo if separate)

## 📄 License

Private project for educational purposes.
