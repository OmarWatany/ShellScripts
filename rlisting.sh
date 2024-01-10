#!/bin/bash
# DESC : a tree_command like script 
# AUTHOR: Omar Watany
# list directories recursively with it's full path
# so i can use them more easily

if [[ "$1" == "" ]]
then
  CDIR=`cd $(dirname "$BASH_RESOURCE[0]") && pwd`
else
  CDIR=`echo "$1"`
fi

lst(){
  for I in "$1"/* ; do 
      case $(file --mime-type -Lb "$I") in 
        inode/directory)
          echo "->> Dir: $I";
          # to the start and the end of each directory
          lst "$I" 
          ;;
        *)
            echo "$I";
          ;;
      esac;
  done
}

lst "$CDIR"
