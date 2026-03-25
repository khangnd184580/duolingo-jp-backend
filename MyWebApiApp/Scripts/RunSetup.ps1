# Runs SQL setup in order (paths relative to this script).
param(
    [string] $ServerInstance = "LAPTOP-4PCI4JO1\YUKICUTE",
    [string] $Database = "DuolingoJP"
)
$ErrorActionPreference = "Stop"
$here = $PSScriptRoot

foreach ($f in @(
        "FixDatabaseForCurrentBackend.sql",
        "SeedLearningContent_EfCompatible.sql",
        "SeedShopItems.sql"
    )) {
    $path = Join-Path $here $f
    if (-not (Test-Path $path)) { throw "Missing file: $path" }
    Write-Host "Running $f ..."
    sqlcmd -S $ServerInstance -d $Database -E -i $path
    if ($LASTEXITCODE -ne 0) { throw "sqlcmd failed on $f (exit $LASTEXITCODE)" }
}
Write-Host "Done."
