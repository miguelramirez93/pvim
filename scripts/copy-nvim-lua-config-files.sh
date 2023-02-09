#!/bin/bash
echo "Copying config files"
cp -r ~/.config/nvim/lua/plugins ~/.config/plugins_bk
rm -rf ~/.config/nvim
mkdir -p ~/.config/nvim/lua
mv ~/.config/plugins_bk ~/.config/nvim/lua/plugins 
rm -rf  ~/.config/plugins_bk
cp -r ../lua/* ~/.config/nvim/lua
cp ../init.lua ~/.config/nvim/init.lua
