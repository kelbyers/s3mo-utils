BeforeAll {
    $global:scriptPath = $PSCommandPath.Replace('.Tests.ps1', '.ps1')
    function New-TestArchives {
        # get the timestamp of this file
        $global:myTimestamp = (Get-Item -Path $PSCommandPath).LastWriteTime

        # name of test archive
        $global:testArchiveDir = $(New-TemporaryFile |
            ForEach-Object {
                Remove-Item $_ ; New-Item -Path $_ -ItemType Directory
            })
        $global:testArchiveBaseName = 'test'
        $global:testArchivePath = "${testArchiveDir}\${testArchiveBaseName}.7z"
        $global:testZipPath = "${testArchiveDir}\${testArchiveBaseName}.zip"

        # multi-file archive with different timestamps
        # create a file with a different timestamp
        $global:multiFileTimestamp = $myTimestamp.AddMinutes(-1).AddSeconds(-1)
        $global:multiFileName = 'multiFile.txt'
        $global:multiFilePath = "${testArchiveDir}\${multiFileName}"
        $global:multiFile = New-Item -Path $multiFilePath -ItemType File
        # # add some content to the file
        Get-Content -Path $PSCommandPath | Set-Content -Path $multiFile
        Set-ItemProperty -Path $multiFile -Name LastWriteTime -Value $multiFileTimestamp

        # create the multi-file archive and add several files
        $global:multiFileBaseName = 'multiFile'
        $global:multiFileArchive = "${testArchiveDir}\${multiFileBaseName}.7z"
        7z a "$multiFileArchive" $multiFilePath $PSCommandPath

        # # copy this file to the multi-file archive directory
        # Copy-Item -Path $PSCommandPath -Destination $multiFileDir
        # # set the timestamp of the copied file
        # Set-ItemProperty -Path $PSCommandPath -Name LastWriteTime -Value $myTimestamp

        # # create the multi-file archive
        # Push-Location -Path $multiFileDir
        # $global:multiFileArchive = "${testArchiveDir}\multiFile.7z"
        # 7z a "$multiFileArchive" *

        # archive this file to a 7z archive
        7z a "$testArchivePath" $PSCommandPath

        # use 7z to archive this file to a zip archive
        7z a "$testZipPath" $PSCommandPath
    }
}

Describe 'setup' {
    AfterAll {
        Remove-Item -Path $testArchiveDir -Recurse -Force
    }
    It 'can create test archives' {
        New-TestArchives

        Test-Path -Path $testArchivePath | Should -BeTrue
        Test-Path -Path $testZipPath | Should -BeTrue
        Test-Path -Path $multiFileArchive | Should -BeTrue
    }
}

Describe 'functions' {
    BeforeAll {
        . $scriptPath
        New-TestArchives
    }

    AfterAll {
        Remove-Item -Path $testArchiveDir -Recurse -Force
    }


    Describe 'Get-ArchiveTimestamp' {
        It 'Returns a DateTime object' {
            $timestamp = Get-ArchiveTimestamp -Path $testArchivePath
            $timestamp | Should -BeOfType [DateTime]
        }

        It 'Gets a DateTime object from a zip archive' {
            $timestamp = Get-ArchiveTimestamp -Path $testZipPath
            $timestamp | Should -BeOfType [DateTime]
        }

        It 'Gets a DateTime object from a multi-file archive' {
            $timestamp = Get-ArchiveTimestamp -Path $multiFileArchive
            $timestamp | Should -BeOfType [DateTime]
        }

        It 'Returns the correct timestamp' {
            $timestamp = Get-ArchiveTimestamp -Path $testArchivePath
            $timestamp | Should -Be $myTimestamp
        }

        It 'Returns the correct timestamp from a zip archive' {
            $timestamp = Get-ArchiveTimestamp -Path $testZipPath
            $timestamp | Should -Be $myTimestamp
        }

        It 'Returns the correct timestamp from a multi-file archive' {
            $timestamp = Get-ArchiveTimestamp -Path $multiFileArchive
            $myTimestamp | Should -BeGreaterThan $multiFileTimestamp
            $timestamp | Should -Not -Be $multiFileTimestamp
            $timestamp | Should -Be $myTimestamp
        }
    }

    Describe 'Rename-Archive' {
        It 'renames the archive' {
            Rename-Archive -Path $testArchivePath
            Test-Path -Path $testArchivePath | Should -BeFalse

            # format the timestamp as a string
            $myTimestampString = $myTimestamp.ToString('yyyyMMdd-HHmmss')
            Test-Path -Path "${testArchiveDir}\${testArchiveBaseName}_${myTimestampString}.7z" | Should -BeTrue
        }

        It 'renames the zip archive' {
            Rename-Archive -Path $testZipPath
            Test-Path -Path $testZipPath | Should -BeFalse

            # format the timestamp as a string
            $myTimestampString = $myTimestamp.ToString('yyyyMMdd-HHmmss')
            Test-Path -Path "${testArchiveDir}\${testArchiveBaseName}_${myTimestampString}.zip" | Should -BeTrue
        }

        It 'renames the multi-file archive' {
            Rename-Archive -Path $multiFileArchive
            Test-Path -Path $multiFileArchive | Should -BeFalse

            # format the timestamp as a string
            $myTimestampString = $myTimestamp.ToString('yyyyMMdd-HHmmss')
            Test-Path -Path "${testArchiveDir}\${multiFileBaseName}_${myTimestampString}.7z" | Should -BeTrue
        }
    }
}
Describe 'Rename-Archive script' {
    BeforeAll {
        New-TestArchives

        # format the timestamp as a string
        $global:myTimestampString = $myTimestamp.ToString('yyyyMMdd-HHmmss')
    }
    AfterAll {
        Remove-Item -Path $testArchiveDir -Recurse -Force
    }
    It 'renames the archive' {
        powershell -File $scriptPath $testArchivePath

        Test-Path -Path $testArchivePath | Should -BeFalse

        Test-Path -Path "${testArchiveDir}\${testArchiveBaseName}_${myTimestampString}.7z" | Should -BeTrue
    }

    It 'renames the zip archive' {
        powershell -File $scriptPath $testZipPath

        Test-Path -Path $testZipPath | Should -BeFalse

        Test-Path -Path "${testArchiveDir}\${testArchiveBaseName}_${myTimestampString}.zip" | Should -BeTrue
    }

    It 'renames the multi-file archive' {
        powershell -File $scriptPath $multiFileArchive

        Test-Path -Path $multiFileArchive | Should -BeFalse

        Test-Path -Path "${testArchiveDir}\${multiFileBaseName}_${myTimestampString}.7z" | Should -BeTrue
    }
}
