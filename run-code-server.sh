#!/bin/sh

######################
##       NOTE       ##
######################
: << COMMENT

TROUBLE SHOOTING
If you recieve any errors while trying to access the code-server:
1. Ensure $WEB_HOST is set. If it isn't, open the main cloudshell terminal (should have a black background),
   and see if it's set. `echo $WEB_HOST`. If it is, try running the script in this terminal.

DESCRIPTION
Running this script will start up a new remotely accessible code-server instance.

SECURITY
Authentication is handled by Google's SSO.
Users (you) must first pass Google's SSO to access the cloud shell and resulting code-server over the web.

INSTRUCTIONS
You may customise the port on which code-server starts by changing the $CS_PORT env variable.
Note that you must use an available and allowed port.

CUSTOMISATION
Setting $CS_PORT will change the port on which the server is exposed.
Providing flags to the code-server command:
--auth            | The authentication mechanism to be used. Set to 'none' as this is handled by Google
--host            | The host to run the code-server on
--bind-addr       | Address to bind to in host:port
--log             | Produce extra debugging output if supplied. Options: 'debug' or 'trace'
--trusted-origins | Provide a list of trusted origins - MUST be used to work around Google's proxy

COMMENT


###########################
##   UTILITY FUNCTIONS   ##
###########################

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


###############################################
##     ENSURE DEPENDENCIES ARE INSTALLED     ##
###############################################

## Ensure python installed
echo -n Ensuring python is installed ...
python3 --version > /dev/null 2>&1
if [ "$?" -eq "0" ]
then
  echo -n " Already installed ... "
else
  echo -n " Installing ..."
  sudo apt-get update -y > /dev/null 2>&1
  sudo apt-get install -y python3 > /dev/null 2>&1
  sudo apt-get autoremove -y >/dev/null 2>&1
fi
echo DONE

## Ensure code-server installed
echo -n Ensuring code-server is installed ...
code-server --version > /dev/null 2>&1
if [ "$?" -eq "0" ]
then
  echo -n " Already installed ... "
else
  echo -n " Installing ... "
  curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone > /dev/null 2>&1
  CODE_SERVER_PATH="$HOME/.local/bin"
  path_append "$CODE_SERVER_PATH"
fi
echo DONE


############################
##      START SERVER      ##
############################

## Get a random free port for code-server to use
CS_PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()');
echo Running on port [$CS_PORT]

## Get user origin. Note that this origin must be passed with `--trusted-origins`
## as otherwise Google's proxy will cause a mismatch between expected and actual origin,
## preventing websockets from connecting.
ACTUAL_ORIGIN=$CS_PORT-$WEB_HOST

## Tell the user how to access the code server
echo Access code server IDE using: https://$ACTUAL_ORIGIN

## Run code-server
code-server                                \
    --auth            none                 \
    --bind-addr       127.0.0.1:$CS_PORT   \
    --trusted-origins $ACTUAL_ORIGIN       \
    &> /dev/null
