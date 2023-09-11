#!/bin/sh

##########################
##   HELPER FUNCTIONS   ##
##########################

## Prepends the given line to the given file if it isn't in the file yet.
## NOTE
## * File must exist
## ARGS
## 1 - File to add the line to
## 2 - The line to add
line_prepend_unique() {
    grep -qxF "$2" "$1" || echo "$2"$'\n'"$(cat ${1})" > "$1"
}

## Appends the given line to the given file if it isn't in the file yet.
## NOTE
## * File must exist
## ARGS
## 1 - File to add the line to
## 2 - The line to add
line_append_unique() {
    grep -qF -- "$2" "$1" || echo "$2" >> "$1"
}

## Appends the given path to $PATH only if it isn't in path yet.
## ARGS
## 1 - The path to add
path_append() {
    [[ ":${PATH}:" != *":${1}:"* ]] && export PATH="${PATH}:${1}"
}

## Formats the given path into a $PATH append command as a single string.
## Used for adding path append commands to ~/.bashrc
## ARGS
## 1 - The path to append to $PATH
format_path_append() {
    echo "[[ \":\${PATH}:\" != *\":${1}:\"* ]] && PATH=\"\${PATH}:${1}\""
}

## Adds the given path as a path append command to the ~/.bashrc file
## ARGS
## 1 - The path to add within ~/.bashrc
add_path_to_bashrc() {
    local LINE_TO_ADD=`format_path_append "$1"`
    line_append_unique "~/.bashrc" "$LINE_TO_ADD"
}

## Adds the given path to the ~/.bashrc file and to the current shell
## ARGS
## 1 - The path to add to ~/.bashrc and current shell
add_path() {
    add_path_to_bashrc "$1"
    path_append "$1"
}
