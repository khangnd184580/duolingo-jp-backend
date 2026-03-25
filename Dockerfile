# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

# Copy csproj and restore dependencies
COPY MyWebApiApp/*.csproj ./MyWebApiApp/
RUN dotnet restore ./MyWebApiApp/MyWebApiApp.csproj

# Copy everything else and build
COPY MyWebApiApp/. ./MyWebApiApp/
WORKDIR /app/MyWebApiApp
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

# Expose port (Render will set PORT environment variable)
EXPOSE 10000

# Set environment to Production
ENV ASPNETCORE_ENVIRONMENT=Production

# Use PORT from Render environment variable (default to 10000 if not set)
CMD ASPNETCORE_URLS=http://+:${PORT:-10000} dotnet MyWebApiApp.dll
