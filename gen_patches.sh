#!/usr/bin/env bash

root="$(dirname "$(realpath "$0")")"
source_dir="${root}/source"
patches_dir="${root}/patches"

if [ ! -d "$source_dir" ]; then
    echo "No sourced dir"
    exit 1
fi

(
    cd "$source_dir"

    if git diff-index --quiet HEAD --; then
        echo "Nothing to commit."
        exit 0
    fi

    commit_count="$(git rev-list --count HEAD)"
    
    if [ "$commit_count" -gt 2 ]; then
        echo "There are more than 1 commit in the repository."
        exit 1
    fi

    git add .

    if [ "$commit_count" -eq 2 ]; then
        git commit --amend -m "APPLY PATCH"
    else
        git commit -m "APPLY PATCH"
    fi

    git reset --soft HEAD~1

    rm -rf "$patches_dir"

    git diff HEAD --name-status | while read -r status file other_file; do
        case $status in
            # Deleted
            D*) 
                out_file="$(basename "${file}").diff"
                out="${patches_dir}/${out_file}"
                out_dir="$(dirname "$out")"
                out="${out_dir}/__${out_file}"
                mkdir -p "$out_dir"
                git diff HEAD -- "$file" > "$out"
                ;;

            # Renamed/Copied
            [RC]*) 
                out="${patches_dir}/${other_file}.diff"
                out_dir="$(dirname "$out")"
                mkdir -p "$out_dir"
                git diff HEAD -- "$file" "$other_file" > "$out"
                ;;
            
            # Added/Modified
            *)
                out="${patches_dir}/${file}.diff"
                out_dir="$(dirname "$out")"
                mkdir -p "$out_dir"
                git diff HEAD -- "$file" > "$out"
                ;;
        esac
    done

    git add .
    git commit -m "APPLY PATCH"
)