# Export QuestionOptions with proper IsCorrect handling
# Run in PowerShell

$serverInstance = "LAPTOP-4PCI4JO1\YUKICUTE"
$database = "DuolingoJP"
$outputFile = ".\MyWebApiApp\Scripts\question_options_only.sql"

Write-Host "Exporting QuestionOptions with IsCorrect fix..." -ForegroundColor Green

# Query with ISNULL to handle missing IsCorrect
$query = @"
SELECT 
    OptionId,
    QuestionId,
    OptionText,
    ISNULL(IsCorrect, 1) as IsCorrect
FROM QuestionOptions
ORDER BY OptionId
"@

$data = Invoke-Sqlcmd -ServerInstance $serverInstance -Database $database -Query $query

Write-Host "Found $($data.Count) question options" -ForegroundColor Yellow

$sqlContent = @"
-- ============================================
-- QUESTION OPTIONS ONLY - WITH IsCorrect FIX
-- Total: $($data.Count) options
-- ============================================

-- Delete existing data
DELETE FROM "QuestionOptions";

-- Import all options
"@

$batchSize = 100
$batch = @()

foreach ($row in $data) {
    $optionText = $row.OptionText -replace "'", "''"
    $isCorrect = if ($row.IsCorrect) { "true" } else { "false" }
    
    $batch += "($($row.OptionId), $($row.QuestionId), '$optionText', $isCorrect)"
    
    if ($batch.Count -ge $batchSize) {
        $sqlContent += "INSERT INTO `"QuestionOptions`" (`"OptionId`", `"QuestionId`", `"OptionText`", `"IsCorrect`") VALUES `n"
        $sqlContent += $batch -join ",`n"
        $sqlContent += ";`n`n"
        $batch = @()
    }
}

# Insert remaining
if ($batch.Count -gt 0) {
    $sqlContent += "INSERT INTO `"QuestionOptions`" (`"OptionId`", `"QuestionId`", `"OptionText`", `"IsCorrect`") VALUES `n"
    $sqlContent += $batch -join ",`n"
    $sqlContent += ";`n`n"
}

$sqlContent += @"

-- Update sequence
SELECT setval('"QuestionOptions_OptionId_seq"', (SELECT MAX("OptionId") FROM "QuestionOptions") + 1);

-- Verify count
SELECT COUNT(*) as "Total Options" FROM "QuestionOptions";
"@

$sqlContent | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "`nExport completed!" -ForegroundColor Green
Write-Host "Output file: $outputFile" -ForegroundColor Cyan
Write-Host "File size: $([math]::Round((Get-Item $outputFile).Length / 1KB, 2)) KB" -ForegroundColor Cyan
