#!/bin/bash
echo "Copying config files"
rm -rf ~/.config/nvim
mkdir -p ~/.config/nvim
cp -r ../lua/ ~/.config/nvim/lua
cp ../init.lua ~/.config/nvim/init.lua
