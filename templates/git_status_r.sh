#!/bin/bash

for d in `git submodule | sed -E 's/(.*) (.*) .*/\2/g'` ; do
  echo "################################"
  echo $d
  echo "################################"
  cd $d
  git status
  cd - > /dev/null
  echo ""
done
