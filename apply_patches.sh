#!/usr/bin/env bash

root="$(dirname "$(realpath "$0")")"
source_dir="${root}/source"
patches_dir="${root}/patches"

(
    cd "$source_dir"

    if ! git diff --quiet || ! git diff --cached --quiet || [[ -n $(git ls-files --others --exclude-standard) ]]; then
        echo "Git repository is not clean, run gen_patches.sh"
        exit 1
    fi

    commit_count="$(git rev-list --count HEAD)"

    if [ "$commit_count" -gt 2 ]; then
        echo "There are more than 2 commits in the repository."
        exit 1
    fi

    if [ "$commit_count" -eq 2 ]; then
        echo "Resetting repository"
        git reset --hard HEAD~1
    fi

    find "$patches_dir" -type f -name "*.diff" | while read patch; do
        echo "Applying patch: $patch"
        git apply "$patch"
    done

    git add .
    git commit -m "APPLY PATCH"
)