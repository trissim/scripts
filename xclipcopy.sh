#!/bin/sh
filetype=$(file --mime-type -b $1)
xclip -selection clipboard -t $filetype -i $1
