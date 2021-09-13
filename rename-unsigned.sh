#!/bin/bash

set -evax

cd build

files=(`find ./ -maxdepth 1 -name "*.qpkg.codesigning"`)
if [ ${#files[@]} -gt 0 ]; then 
    exit 0
else 
    ls | xargs -i mv {} unsigned_{}
fi
