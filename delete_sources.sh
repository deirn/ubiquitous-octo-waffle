#!/usr/bin/env bash

root="$(dirname "$(realpath "$0")")"
source_dir="${root}/source"

find "$source_dir" -type d -delete
rm "$source_dir"