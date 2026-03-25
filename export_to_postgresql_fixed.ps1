# Export SQL Server data to PostgreSQL format - FIXED VERSION
# Run this in PowerShell

$serverInstance = "LAPTOP-4PCI4JO1\YUKICUTE"
$database = "DuolingoJP"
$outputFile = ".\MyWebApiApp\Scripts\full_data_export_postgresql.sql"

Write-Host "Exporting database from SQL Server to PostgreSQL format..." -ForegroundColor Green

# Start building the SQL file
$sqlContent = @"
-- ============================================
-- FULL DATABASE EXPORT FROM SQL SERVER TO POSTGRESQL
-- Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
-- ============================================

-- Disable triggers and constraints temporarily
SET session_replication_role = replica;

"@

# Function to get column names from table
function Get-TableColumns {
    param($tableName)
    $query = @"
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '$tableName'
AND COLUMN_NAME NOT IN ('RowState', 'ItemArray', 'HasErrors')
ORDER BY ORDINAL_POSITION
"@
    return Invoke-Sqlcmd -ServerInstance $serverInstance -Database $database -Query $query | Select-Object -ExpandProperty COLUMN_NAME
}

# Function to convert SQL Server INSERT to PostgreSQL
function Export-Table {
    param($tableName, $pgTableName)
    
    Write-Host "Exporting $tableName..." -ForegroundColor Yellow
    
    $columns = Get-TableColumns $tableName
    $columnNames = $columns -join ','
    
    $query = "SELECT $columnNames FROM [$tableName]"
    $data = Invoke-Sqlcmd -ServerInstance $serverInstance -Database $database -Query $query
    
    if ($data.Count -eq 0) {
        return "-- No data in $pgTableName`n"
    }
    
    $result = "`n-- ============================================`n"
    $result += "-- TABLE: $pgTableName`n"
    $result += "-- Count: $($data.Count) rows`n"
    $result += "-- ============================================`n"
    $result += "DELETE FROM `"$pgTableName`";`n`n"
    
    foreach ($row in $data) {
        $cols = @()
        $vals = @()
        
        foreach ($col in $columns) {
            $value = $row.$col
            
            if ($value -ne [DBNull]::Value -and $null -ne $value) {
                $cols += "`"$col`""
                
                # Handle different data types
                if ($value -is [string]) {
                    $escapedValue = $value -replace "'", "''"
                    $vals += "'$escapedValue'"
                }
                elseif ($value -is [bool]) {
                    $vals += if ($value) { "true" } else { "false" }
                }
                elseif ($value -is [DateTime]) {
                    $vals += "'$($value.ToString("yyyy-MM-ddTHH:mm:ss"))'"
                }
                elseif ($value -is [int] -or $value -is [long] -or $value -is [decimal] -or $value -is [double]) {
                    $vals += $value
                }
                else {
                    # Default: treat as string
                    $escapedValue = $value.ToString() -replace "'", "''"
                    $vals += "'$escapedValue'"
                }
            }
        }
        
        if ($cols.Count -gt 0) {
            $result += "INSERT INTO `"$pgTableName`" ($($cols -join ', ')) VALUES ($($vals -join ', '));`n"
        }
    }
    
    return $result
}

# Export tables in order (respecting foreign keys)
$sqlContent += Export-Table "Level" "Level"
$sqlContent += Export-Table "Topic" "Topic"
$sqlContent += Export-Table "Lessons" "Lessons"
$sqlContent += Export-Table "Questions" "Questions"
$sqlContent += Export-Table "QuestionOptions" "QuestionOptions"
$sqlContent += Export-Table "Items" "Items"
$sqlContent += Export-Table "Achievements" "Achievements"
$sqlContent += Export-Table "Tasks" "Tasks"

# Re-enable constraints
$sqlContent += @"

-- Re-enable triggers and constraints
SET session_replication_role = DEFAULT;

-- Update sequences to prevent ID conflicts
DO `$`$
BEGIN
    PERFORM setval('"Level_LevelId_seq"', (SELECT COALESCE(MAX("LevelId"), 0) + 1 FROM "Level"));
    PERFORM setval('"Topic_TopicId_seq"', (SELECT COALESCE(MAX("TopicId"), 0) + 1 FROM "Topic"));
    PERFORM setval('"Lessons_LessonId_seq"', (SELECT COALESCE(MAX("LessonId"), 0) + 1 FROM "Lessons"));
    PERFORM setval('"Questions_QuestionId_seq"', (SELECT COALESCE(MAX("QuestionId"), 0) + 1 FROM "Questions"));
    PERFORM setval('"QuestionOptions_OptionId_seq"', (SELECT COALESCE(MAX("OptionId"), 0) + 1 FROM "QuestionOptions"));
    PERFORM setval('"Items_ItemId_seq"', (SELECT COALESCE(MAX("ItemId"), 0) + 1 FROM "Items"));
    PERFORM setval('"Achievements_AchievementId_seq"', (SELECT COALESCE(MAX("AchievementId"), 0) + 1 FROM "Achievements"));
    PERFORM setval('"Tasks_TaskId_seq"', (SELECT COALESCE(MAX("TaskId"), 0) + 1 FROM "Tasks"));
END `$`$;

-- Verify import
SELECT 'Levels:' as "Table", COUNT(*) as "Count" FROM "Level"
UNION ALL SELECT 'Topics:', COUNT(*) FROM "Topic"
UNION ALL SELECT 'Lessons:', COUNT(*) FROM "Lessons"
UNION ALL SELECT 'Questions:', COUNT(*) FROM "Questions"
UNION ALL SELECT 'Question Options:', COUNT(*) FROM "QuestionOptions"
UNION ALL SELECT 'Items:', COUNT(*) FROM "Items"
UNION ALL SELECT 'Achievements:', COUNT(*) FROM "Achievements"
UNION ALL SELECT 'Tasks:', COUNT(*) FROM "Tasks";

-- Analyze tables for better query performance
ANALYZE;
"@

# Save to file
$sqlContent | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline

Write-Host "`nExport completed successfully!" -ForegroundColor Green
Write-Host "Output file: $outputFile" -ForegroundColor Cyan
Write-Host "File size: $([math]::Round((Get-Item $outputFile).Length / 1KB, 2)) KB" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Open Render Dashboard -> PostgreSQL Database"
Write-Host "2. Click 'PSQL Console' or 'Connect'"
Write-Host "3. Copy ALL content from $outputFile"
Write-Host "4. Paste into console and execute"
Write-Host "5. Wait for completion (may take 1-2 minutes)"
