# This is a description of how S3MO organizes its configuration and managed mods

## Files and Directories

- The application, its configuration, and all of its managed mods are located
  within the S3MO base directory
- The S3MO base directory can be anywhere the user wishes on the system
- The `Mods` directory is in the S3MO base directory
  - Each managed mod must be in a directory directly under the `Mods` directory
  - S3MO refers to each mod by the name of the mod directory
  - `*.package` files must be immediately under the mod directory, and cannot be
    nested in sub-directories
  - `*.package` files are what actually provide the functionality of the mod
  - There are restrictions on what the name of a mod directory can be:
    - The name can only contain `- _(){}[]&`, or alphanumeric characters
- The `Profiles` directory is in the S3MO base directory
  - Each profile is a directory in the `Profiles` directory
  - S3MO treats the name of the directory as the name of the profile
  - Each profile directory contains a `modlist.txt` file
  - The format of the `modlist.txt` file is:
    - one line per mod in the `Mods` directory
    - The first character of the list indicates whether the mod is enabled or
      disabled:
      - `-` = disabled
      - `+` = enabled
  - A convention followed by users, but not enforced by the program, is to
    organize related mods together.
    - Each organized section is identified by an
      empty folder. The name of the empty folder is a series of multiple `-`
      characters, followed by a ` `, and then the name of the section.
    - All mods between organizer labels belong to the section of the preceding
      organizer label.
    - The very last organizer label is `LEAVE AT BOTTOM`.
    - Any mods below that label have not been organized yet.
