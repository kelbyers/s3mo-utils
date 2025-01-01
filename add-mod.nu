# nu

use std log

def get-mod-name [source] {
  $source | path parse | get stem
}

def extract [archive destination] {
  log debug $"Extracting from `($archive)` to `($destination)`"

  if ($destination | path exists) {
      log warning $"Already exists: ($destination)"
      return 1
  }

  do {7z e $"($archive)" -o$"($destination)"}
  let exit_code = $env.LAST_EXIT_CODE
  if $exit_code != 0 {
    log error "Unexpected error!"
    log error $"7z exited with ($exit_code)"
    return 1
  }
  return 0
}

def copy-package [package destination] {
  let package_path = ($destination + "\\" + ($package | path basename))
  log debug $"package_path = ($package_path)"
  log debug $"package = ($package)"
  log debug $"destination = ($destination)"
  if ($package_path | path exists) {
    log warning $"Already exists: ($package_path)"
    return 1
  }

  mkdir --verbose $destination
  cp --verbose --no-clobber $package $destination
  return $env.LAST_EXIT_CODE
}

def "main" [...mods] {
  let mods_directory = $env.PWD

  log info $"Mods Location ($mods_directory)"

  let count = ($mods | length)
  log info $"($count) archives..."

  let errors = ($mods | each {
    mut my_errors = 0
    let mod_source = $in
    let mod_name = (get-mod-name $mod_source | str replace --all '.' '_')
    let mod_directory = ($mods_directory + "\\" + $mod_name)
    let mod_type = ($mod_source | path parse | get extension)

    if $mod_type == "package" {
      log info $"Copying package file: ($mod_name)"
      $my_errors = (copy-package $mod_source $mod_directory)
    } else {
      log info $"Extracting archive: ($mod_name)"
      $my_errors = (extract $mod_source $mod_directory)
    }
    if $count < 5 { start $mod_directory }

    return $my_errors
  } | math sum)

  log warning $"Encountered ($errors) errors"

  input 'Done> '

  exit $errors
}
