function Get-ArchiveTimestamp {
    # take a string parameter for the path to the archive
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    # use 7z.exe to extract the timestamp from the archive
    $timestamp = (7z l -slt "$Path" |
         Select-String -Pattern 'Modified =' | ForEach-Object{ [DateTime]($_.ToString().Split('=').Trim()[-1]) })

    # get the most recent timestamp
    $mostRecent = ($timestamp | Measure-Object -Maximum).Maximum

    # return the timestamp as a DateTime object
    return $mostRecent
}

function Rename-Archive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    $archive = Get-Item -LiteralPath "$Path"
    $archiveExtension = ${archive}.Extension
    $archiveBaseName = ${archive}.BaseName
    $archiveDirectory = ${archive}.DirectoryName

    # get the timestamp of the archive
    $timestamp = Get-ArchiveTimestamp -Path "$Path"

    # format the timestamp as a string
    $timestamp = $timestamp.ToString('yyyyMMdd-HHmmss')

    # rename the archive with the timestamp
    $newPath = "${archiveDirectory}\${archiveBaseName}_${timestamp}${archiveExtension}"

    # move the archive to the new path
    Move-Item -LiteralPath "$Path" -Destination "$newPath"
}

if ($MyInvocation.InvocationName -ne '.') {
    # for each archive specified on the command line
    foreach ($archive in $args) {
        # rename the archive
        Rename-Archive -Path "$archive"
    }
}
