export PATH=/opt/local/bin:$PATH
export PATH=/opt/local/sbin:$PATH
export PATH=~/Development/scripts/:$PATH

export MANPATH=/opt/local/share/man:$MANPATH

export SVN_EDITOR=vi

# bigger history	
export HISTFILESIZE=1000000000
export HISTSIZE=1000000

# ignore identical commands
export HISTCONTROL=ignoreboth
export HISTIGNORE="ls"

shopt -s histappend #append to the samme history file when using multiple terminals
shopt -s cdspell #minor errors in the spelling of a directory component in a cd command will be corrected
shopt -s nocaseglob #when typing part of a filename and press Tab to autocomplete, Bash does a case-insensitive search.	

#!/bin/bash
#
# Provides a function that allows you to choose a JDK.  Just set the environment 
# variable JDKS_ROOT to the directory containing multiple versions of the JDK
# and the function will prompt you to select one.  JAVA_HOME and PATH will be cleaned
# up and set appropriately.

# Usage:
# Include in .profile or .bashrc or source at login to get 'pickjdk' command.
# 'pickjdk' alone to bring up a menu of installed JDKs on OS X. Select one.
# 'pickjdk <jdk number>' to immediately switch to one of those JDKs.

_macosx()
{
    if [ $(uname -s) = Darwin ]; then
        return 0
    else
        return 1
    fi
}

JDKS_ROOT=
if _macosx; then
    JDKS_ROOT=/System/Library/Frameworks/JavaVM.framework/Versions
fi

pickjdk()
{
    if [ -z "$JDKS_ROOT" ]; then
        return 1
    fi

    declare -a JDKS
    local n=1 jdk total_jdks choice=0 currjdk=$JAVA_HOME explicit_jdk
    for jdk in $JDKS_ROOT/[0-9osdM]*; do
        if [ -d $jdk -a ! -L $jdk ]; then
            JDKNAMES[$n]="$(basename $jdk)"
            if _macosx; then
                jdk=$jdk/Home
            fi
            if [ -z "$1" ]; then
              echo -n " $n) ${JDKNAMES[$n]}"
              if [ $jdk = "$currjdk" ]; then
                  echo " < CURRENT"
              else
                  echo
              fi
            fi
            JDKS[$n]=$jdk
            total_jdks=$n
            n=$[ $n + 1 ]
        fi
    done
    if [ -z "$1" ]; then
      echo " $n) None"
    fi
    JDKS[$n]=None
    total_jdks=$n

    if [ $total_jdks -gt 1 ]; then
        if [ -z "$1" ]; then
          while [ -z "${JDKS[$choice]}" ]; do
              echo -n "Choose one of the above [1-$total_jdks]: "
              read choice
          done
        else
          choice=$1
        fi
    fi

    if [ -z "$currjdk" ]; then
        currjdk=$(dirname $(dirname $(type -path java)))
    fi

    if [ ${JDKS[$choice]} != None ]; then
        export JAVA_HOME=${JDKS[$choice]}
    else
        unset JAVA_HOME
    fi

    explicit_jdk=
    for jdk in ${JDKS[*]}; do
        if [ "$currjdk" = "$jdk" ]; then
            explicit_jdk=$jdk
            break
        fi
    done

    if [ "$explicit_jdk" ]; then
        if [ -z "$JAVA_HOME" ]; then
            PATH=$(echo $PATH | sed "s|$explicit_jdk/bin:*||g")
        else
            PATH=$(echo $PATH | sed "s|$explicit_jdk|$JAVA_HOME|g")
        fi
    elif [ "$JAVA_HOME" ]; then
        PATH="$JAVA_HOME/bin:$PATH"
    fi

    echo "New JDK: ${JDKNAMES[$choice]}"

    hash -r
    unset JDKS
}