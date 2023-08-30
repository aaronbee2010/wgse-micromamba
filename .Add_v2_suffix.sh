#!/usr/bin/env bash
#
# Add failsafe to prevent a non-developer from running this script
if [[ $# -ne 1 ]] ; then
  printf "Usage: source %s dummy\n" "$0"
  printf "  dummy is anything; required to avoid direct user click.\n"
  printf "  This script should only be executed by a developer.\n"
  (return 0 2>/dev/null) && return || exit
fi

for script in {.,./scripts}/*.sh; do
    sed -i 's/\.sh/_v2.sh/g' ${script}
    mv ${script} ${script/\.sh/_v2.sh}
done
