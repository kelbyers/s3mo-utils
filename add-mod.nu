# nu

use std log

def get-archive-name [archive] {
  let start = ($archive | str index-of --end "\\" | [1 $in] | math sum)
  let end = ($archive | str index-of --end "." | [-1 $in ] | math sum)
  $archive | str substring $start..$end
}

def "main extract" [...archives] {
  # let mods_directory: string = $env.FILE_PWD
  let mods_directory = $env.PWD

  print $"Mods Location ($mods_directory)"

  let count = ($archives | length)
  print $"($count) archives..."

  $archives | each {

    let archive = $in
    let mod_name = (get-archive-name $archive | str replace --all '.' '_')
    let mod_directory = ($mods_directory + "\\" + $mod_name)

    if ($mod_directory | path exists) {
      log warning $"Already exists: ($mod_directory)"
    } else {
      # print $mod_directory

      do {7z e $"($archive)" -o$"($mod_directory)"}
      let exit_code = $env.LAST_EXIT_CODE
      if $exit_code != 0 {
        log error "Unexpected error!"
        log error $"7z exited with ($exit_code)"
        input
        exit $exit_code
      }
      if $count < 5 { explorer $"($mod_directory)" }
    }
  }

  input 'Done> '

  exit 0
}

def main [] {}
