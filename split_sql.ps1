# Split SQL file into smaller chunks for easier import
# Run in PowerShell

$inputFile = ".\MyWebApiApp\Scripts\full_data_export_postgresql.sql"
$outputDir = ".\MyWebApiApp\Scripts\split"

# Create output directory
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

Write-Host "Splitting SQL file into chunks..." -ForegroundColor Green

$content = Get-Content $inputFile -Raw

# Split by table sections
$sections = @{
    "01_setup" = @"
-- Setup
SET session_replication_role = replica;
"@
    "02_levels" = ($content -split "-- TABLE: Topic")[0] -replace "^.*-- TABLE: Level", "-- TABLE: Level"
    "03_topics" = "-- TABLE: Topic" + (($content -split "-- TABLE: Topic")[1] -split "-- TABLE: Lessons")[0]
    "04_lessons" = "-- TABLE: Lessons" + (($content -split "-- TABLE: Lessons")[1] -split "-- TABLE: Questions")[0]
    "05_questions" = "-- TABLE: Questions" + (($content -split "-- TABLE: Questions")[1] -split "-- TABLE: QuestionOptions")[0]
    "06_options" = "-- TABLE: QuestionOptions" + (($content -split "-- TABLE: QuestionOptions")[1] -split "-- TABLE: Items")[0]
    "07_items" = "-- TABLE: Items" + (($content -split "-- TABLE: Items")[1] -split "-- TABLE: Achievements")[0]
    "08_achievements" = "-- TABLE: Achievements" + (($content -split "-- TABLE: Achievements")[1] -split "-- TABLE: Tasks")[0]
    "09_tasks" = "-- TABLE: Tasks" + (($content -split "-- TABLE: Tasks")[1] -split "-- Re-enable")[0]
    "10_finalize" = ($content -split "-- Re-enable")[1]
}

foreach ($name in $sections.Keys | Sort-Object) {
    $outFile = Join-Path $outputDir "$name.sql"
    $sections[$name] | Out-File -FilePath $outFile -Encoding UTF8
    Write-Host "Created: $name.sql" -ForegroundColor Yellow
}

Write-Host "`nSplit completed! Files in: $outputDir" -ForegroundColor Green
Write-Host "Import order: 01 -> 02 -> 03 -> ... -> 10" -ForegroundColor Cyan
