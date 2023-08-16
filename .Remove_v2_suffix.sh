#!/usr/bin/env bash

for script in {.,scripts}/*.sh; do
    sed -i 's/_v2\.sh/.sh/' ${script}
    mv ${script} ${script/_v2\.sh/.sh}
done
