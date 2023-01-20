#!/bin/bash
source ./utils.sh
echo "Checking software dependencies"
dependences=(node go)

for dep in "${dependences[@]}"; do command_exist $dep; done

