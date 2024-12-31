#!/usr/bin/env bash

tag="243.22562.218"

root="$(dirname "$(realpath "$0")")"
source_dir="${root}/source"

if [ -d "$source_dir" ]; then
    echo "source directory already exists"
    exit 1
fi

git_url="https://github.com/JetBrains/intellij-community.git"

git clone --depth 1 --branch "idea/${tag}" "${git_url}" "$source_dir"
