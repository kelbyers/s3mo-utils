# S3MO Tools

## cpcfolder.bat

`cpfolder.bat` is a batch script that copies mod folders from a specified location to the `Mods` directory. It takes one or more mod folder names as arguments.

Here's how it works:

1. It creates a new folder in the `Mods` directory with the same name as the mod folder.
2. It copies the contents of the original mod folder to the new folder.
3. If the mod folder is copied successfully, it opens the new folder in Windows Explorer.

You can use `cpfolder.bat` to easily organize your mods into separate folders within the `Mods` directory.

There is a copy of this script in the S3MO `Mods` directory. In the Windows shell,
a source mod folder can be dropped onto the script.

## enfolder.bat

`enfolder.bat` is a batch script that takes a `*.package` file as input, creates a new mod directory for it, and then moves the package file into the mod directory.

Here's how it works:

1. It creates a new folder in the `Mods` directory with a name derived from the package file
2. It moves the package file into the new folder
3. If the mod folder is created successfully, it opens the new folder in Windows Explorer.

There is a copy of this script in the S3MO `Mods` directory. In the Windows shell,
a package file can be dropped onto the script.

## extractor.bat

`extractor.bat` is a batch script that extracts `*.package` files from an archive file.

Here's how it works:

1. It takes an archive file as input.
2. It extracts the `*.package` files from the archive to a new directory.
3. It does flatten the directory structure, placing all files into the new directory
4. It creates any directories in the archive as empty directories

You can use `extractor.bat` to easily extract `*.package` files from archive files.

There is a copy of this script in the S3MO `Mods` directory. In the Windows shell,
an archive can be dropped onto the script.

## s3mo-cleanup.ps1

- Identify mods that are found in the S3MO `Mods` folder but are not enabled in any of the existing profiles.
- Optional flag `-MoveToTrash` outputs command lines for each mod to use the `recycle-bin` command to move the unused mod folder to the system recycle bin.
- A required `-IgnoreFile` parameter provides a path to a file containing one regex per line that tells the script to ignore disabled mods matching the pattern
- required `-S3moDir` parameter gives the path to the S3MO directory, which contains the `Profiles` and `Mods` directories
- e.g.: `powershell -File .\s3mo-cleanup.ps1 -S3moDir "C:\Users\kel\Documents\Electronic Arts\2 Common S3MO" -IgnoreFile .\ignore.txt`

## Rename-Archive

- `Rename-ArchiveTimestamp.ps1`
	- renames an archive that contains a mod, appending a timestamp onto the name of the archive file
	- the timestamp is based on the youngest file in the archive
	- the timestamp format is `YYYYmmdd-HHMMSS`
	- E.g., running the script on an archive file named `Bob-Mod.7z` will look at all the archive members of the file, and get the timestamps for each archive member. If the most recently updated file in the archive has a timestamp of `January 2, 2024 @ 1:45:23PM`, then the archive will be renamed to `Bob-Mod_20240102-134523.7z`
- `Rename-Archive` (`Rename-Archive.lnk`)
	- A windows shell shortcut that will correctly run `Rename-ArchiveTimestatmp.ps1` from the shell
	- An archive file can be dropped onto the shortcut and the archive file will be renamed
	- The shortcut can (and should) be copied anywhere it would be convenient to use
	- The shortcut does not need to be located where the archive is
	- The archive will remain in its original parent directory after being renamed


## Other

- `add-mod.nu`
  - half assed attempt at cleanly extracting mods with the right format and name for S3MO to use
  - probably don't use
