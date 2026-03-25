# Export SQL Server data to PostgreSQL format
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

# Function to convert SQL Server INSERT to PostgreSQL
function Export-Table {
    param($tableName, $pgTableName)
    
    Write-Host "Exporting $tableName..." -ForegroundColor Yellow
    
    $query = "SELECT * FROM [$tableName]"
    $data = Invoke-Sqlcmd -ServerInstance $serverInstance -Database $database -Query $query
    
    if ($data.Count -eq 0) {
        return "-- No data in $pgTableName`n"
    }
    
    $result = "`n-- ============================================`n"
    $result += "-- TABLE: $pgTableName`n"
    $result += "-- ============================================`n"
    $result += "DELETE FROM `"$pgTableName`";`n`n"
    
    foreach ($row in $data) {
        $columns = @()
        $values = @()
        
        foreach ($prop in $row.PSObject.Properties) {
            if ($prop.Value -ne [DBNull]::Value -and $prop.Value -ne $null) {
                $columns += "`"$($prop.Name)`""
                
                # Handle different data types
                if ($prop.Value -is [string]) {
                    $escapedValue = $prop.Value -replace "'", "''"
                    $values += "'$escapedValue'"
                }
                elseif ($prop.Value -is [bool]) {
                    $values += if ($prop.Value) { "true" } else { "false" }
                }
                elseif ($prop.Value -is [DateTime]) {
                    $values += "'$($prop.Value.ToString("yyyy-MM-dd HH:mm:ss"))'"
                }
                else {
                    $values += $prop.Value
                }
            }
        }
        
        $result += "INSERT INTO `"$pgTableName`" ($($columns -join ', ')) VALUES ($($values -join ', '));`n"
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

-- Update sequences
SELECT setval('"Level_LevelId_seq"', (SELECT MAX("LevelId") FROM "Level"));
SELECT setval('"Topic_TopicId_seq"', (SELECT MAX("TopicId") FROM "Topic"));
SELECT setval('"Lessons_LessonId_seq"', (SELECT MAX("LessonId") FROM "Lessons"));
SELECT setval('"Questions_QuestionId_seq"', (SELECT MAX("QuestionId") FROM "Questions"));
SELECT setval('"QuestionOptions_OptionId_seq"', (SELECT MAX("OptionId") FROM "QuestionOptions"));
SELECT setval('"Items_ItemId_seq"', (SELECT MAX("ItemId") FROM "Items"));
SELECT setval('"Achievements_AchievementId_seq"', (SELECT MAX("AchievementId") FROM "Achievements"));
SELECT setval('"Tasks_TaskId_seq"', (SELECT MAX("TaskId") FROM "Tasks"));

-- Verify import
SELECT 'Levels:' as "Table", COUNT(*) as "Count" FROM "Level"
UNION ALL SELECT 'Topics:', COUNT(*) FROM "Topic"
UNION ALL SELECT 'Lessons:', COUNT(*) FROM "Lessons"
UNION ALL SELECT 'Questions:', COUNT(*) FROM "Questions"
UNION ALL SELECT 'Question Options:', COUNT(*) FROM "QuestionOptions"
UNION ALL SELECT 'Items:', COUNT(*) FROM "Items"
UNION ALL SELECT 'Achievements:', COUNT(*) FROM "Achievements"
UNION ALL SELECT 'Tasks:', COUNT(*) FROM "Tasks";

VACUUM ANALYZE;
"@

# Save to file
$sqlContent | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "`nExport completed!" -ForegroundColor Green
Write-Host "Output file: $outputFile" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Open the generated SQL file"
Write-Host "2. Copy all content"
Write-Host "3. Run it in Render PostgreSQL Console"
