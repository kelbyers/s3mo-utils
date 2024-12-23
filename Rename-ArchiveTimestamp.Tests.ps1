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

        # an archive with weird characters in the name
        $global:weirdBaseName = 'weird[Name]'
        $global:weirdArchive = "${testArchiveDir}\${weirdBaseName}.7z"
        Copy-Item -Path $multiFileArchive -Destination $weirdArchive

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

        Test-Path -LiteralPath $testArchivePath | Should -BeTrue
        Test-Path -LiteralPath $testZipPath | Should -BeTrue
        Test-Path -LiteralPath $multiFileArchive | Should -BeTrue
        Test-Path -LiteralPath $weirdArchive | Should -BeTrue
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

        It 'Gets a DateTime object from a weird name archive' {
            $timestamp = Get-ArchiveTimestamp -Path $weirdArchive
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

        It 'Returns the correct timestamp from a weird name archive' {
            $timestamp = Get-ArchiveTimestamp -Path $weirdArchive
            $timestamp | Should -Be $myTimestamp
        }

    }

    Describe 'Rename-Archive' {
        BeforeAll {
            # format the timestamp as a string
            $global:myTimestampString = $myTimestamp.ToString('yyyyMMdd-HHmmss')
        }

        It 'renames the archive' {
            Rename-Archive -Path $testArchivePath
            Test-Path -Path $testArchivePath | Should -BeFalse

            Test-Path -Path "${testArchiveDir}\${testArchiveBaseName}_${myTimestampString}.7z" | Should -BeTrue
        }

        It 'renames the zip archive' {
            Rename-Archive -Path $testZipPath
            Test-Path -Path $testZipPath | Should -BeFalse

            Test-Path -Path "${testArchiveDir}\${testArchiveBaseName}_${myTimestampString}.zip" | Should -BeTrue
        }

        It 'renames the multi-file archive' {
            Rename-Archive -Path $multiFileArchive
            Test-Path -Path $multiFileArchive | Should -BeFalse

            Test-Path -Path "${testArchiveDir}\${multiFileBaseName}_${myTimestampString}.7z" | Should -BeTrue
        }

        It 'renames the weird name archive' {
            Rename-Archive -Path $weirdArchive

            # the original archive should not exist
            Test-Path -Path $weirdArchive | Should -BeFalse

            # the renamed archive should exist
            Test-Path -LiteralPath "${testArchiveDir}\${weirdBaseName}_${myTimestampString}.7z" | Should -BeTrue
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

    It 'renames the weird name archive' {
        powershell -File $scriptPath $weirdArchive

        # the original archive should not exist
        Test-Path -LiteralPath $weirdArchive | Should -BeFalse

        # the renamed archive should exist
        Test-Path -LiteralPath "${testArchiveDir}\${weirdBaseName}_${myTimestampString}.7z" | Should -BeTrue
    }
}
