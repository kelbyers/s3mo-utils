param (
    [string]$S3moDir,
    [string]$IgnoreFile,
    [switch]$MoveToTrash
)

# Get a list of all mod directories in the Mods directory
$modsDir = Join-Path -Path $S3moDir -ChildPath 'Mods'
$modDirs = Get-ChildItem -Path $modsDir -Directory -Name

# Get a list of all enabled mods in all profiles
$profilesDir = Join-Path -Path $S3moDir -ChildPath 'Profiles'
$enabledMods = Get-ChildItem -Path $profilesDir -Directory | ForEach-Object {
    $profileDir = $_
    $modlistFile = Join-Path -Path $profileDir.FullName -ChildPath 'modlist.txt'
    Get-Content -Path $modlistFile | Where-Object { $_ -match '^+' -and $_ -notmatch '^-' } | ForEach-Object {
        $_.TrimStart('+')
    }
} | Sort-Object | Get-Unique

# Get the ignore regular expressions from the file
$ignoreRegexes = Get-Content -Path $IgnoreFile

# Find mod directories that are not enabled in any profile and do not match any ignore regex
$disabledMods = $modDirs | Where-Object {
    $modName = $_
    $enabledMods -notcontains $modName -and
    -not ($ignoreRegexes | Where-Object { $modName -match $_ })
}

if ($MoveToTrash) {
    foreach ($mod in $disabledMods) {
        $modPath = Join-Path -Path $modsDir -ChildPath $mod
        Write-Host "recycle-bin '$modPath'"
    }
} else {
    Write-Host ($disabledMods -join "`n")
}
