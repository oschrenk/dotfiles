#!/bin/sh

rm -rf /tmp/SbarLua
git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua 
cd /tmp/SbarLua/ || exit
make install 
rm -rf /tmp/SbarLua/

