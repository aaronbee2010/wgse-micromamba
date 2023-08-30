#!/usr/bin/env bash

for script in {.,./scripts}/*.sh; do
    sed -i 's/\.sh/_v2.sh/g' ${script}
    mv ${script} ${script/\.sh/_v2.sh}
done
