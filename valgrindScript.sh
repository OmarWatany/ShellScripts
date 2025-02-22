#!/bin/bash

valgrind --leak-check=full \
         --show-leak-kinds=definite,indirect,possible \
         --log-file=valgrind-out.txt \
         --errors-for-leak-kinds=definite,indirect \
         "$1"
