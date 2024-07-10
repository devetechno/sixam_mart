#!/bin/bash

clear

read -p "Enter the old commit hash: " old_commit
read -p "Enter the new commit hash: " new_commit

changed_files=$(git diff --name-only $old_commit $new_commit)

cd "$(git rev-parse --show-toplevel)"

output_dir="changed_files"
mkdir -p $output_dir

for file in $changed_files; do
    mkdir -p "$output_dir/$(dirname $file)"
    cp "$file" "$output_dir/$file"
done

rm 'changed_files.zip'
zip_file="changed_files.zip"
zip -r $zip_file $output_dir
rm -rf $output_dir

echo "Changed files between $old_commit and $new_commit are saved in $zip_file"

