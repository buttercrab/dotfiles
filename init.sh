#!/usr/bin/env bash

while IFS= read -r line; do
    ln -s "~/$line" "./$line"
done < dotfile_list

