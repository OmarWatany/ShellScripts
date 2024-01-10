#!/bin/bash

BDIR=`cd $(dirname "$BASH_SOURCE[0]") && pwd`

for I in *.md; do

  md2html $I > $BDIR/web/$(echo $I | sed 's/.md//').html
  
done
