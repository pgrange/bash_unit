#!/usr/bin/env bash

echo "downloading bash_unit"
current_working_dir=$PWD
tarball_url=$(curl -s https://api.github.com/repos/pgrange/bash_unit/releases | grep tarball_url | head -n 1 | cut -d '"' -f 4)
tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'tmpdir')
cd "${tmp_dir}" || exit 1
curl -Ls "${tarball_url}" | tar -xz -f -
find "${tmp_dir}" -maxdepth 2 -type f -name "bash_unit" -exec cp {} "${current_working_dir}" \;
rm -rf "${tmp_dir}"
echo "thank you for downloading bash_unit, you can now run ./bash_unit"
