#!/usr/bin/env bash

while IFS= read -r line; do
    cp ".$line" "~/$line"
done < dotfile_list
