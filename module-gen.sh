#!/usr/bin/env bash

if [[ $# -lt 1 || $1 == '--help' || $1 == '-h' ]]; then
	echo "Usage: $0 <fonts>"
	exit 1
fi


SFMG_VER='v1.0'
answer='n'

while true; do
	clear

	echo -e "Systemless Font Module Generator - $SFMG_VER by @whirlt

Before generating a module, please take all of the following in account:

- I am not responsible for any damage caused by this tool. Although damage is very unlikely.
- Every module generated with this tool is made to be used with \033[1;4mMagisk\033[0m although it should work on \033[1;4mKernelSU\033[0m or \033[1;4mAPatch\033[0m.
- For the generation to work, you need \033[1;4mzip\033[0m as well as \033[1;4mwget\033[0m installed on your computer.
- You will need an internet connection, unless the install script is present in the working directory.
- Using an unix-like operating system like GNU/Linux is recommended.
"

	for i in $@; do
		[[ ! -f $i ]] && echo -e "\033[31;1mWARNING!\033[0m '$i' wasn't found, proceed with caution.
		"
	done

	read -p $'\033[32;1m>\033[0m Give the module a name! ' mod_name
	read -p $'\033[32;1m>\033[0m And a short description. ' mod_desc
	read -p $'\033[32;1m>\033[0m Finally an ID. ' mod_id
	read -p $'
\033[31;1m>\033[0m May I ask who you are? ' mod_auth

	echo ""

	read -p "Is this correct? (y/N)

NAME: $mod_name
DESCRIPTION: '$mod_desc'
AUTHOR: $mod_auth

ID: $mod_id

The version number won't update automatically.
" answer

	[[ $answer == 'y' || $answer == 'Y' ]] && break
done

# CREATING MODULE FILE TREE

echo '
[*] Generating file tree...'

mkdir -p $mod_id/{system/fonts,META-INF/com/google/android}

# COPYING FILES

echo '[*] Copying fonts over...'

for i in $@; do
	cp $i $mod_id/system/fonts
done

# GENERATING 'module.prop'

echo "[*] Generating 'module.prop'..."

echo "id=$mod_id
name=$mod_name
version=1.0
versionCode=0
author=$mod_auth
description=$mod_desc" > $mod_id/module.prop

# FETCHING INSTALL SCRIPT

echo "[*] Fetching install script...
"

[[ ! -f ./module_installer.sh ]] && wget 'https://github.com/topjohnwu/Magisk/blob/master/scripts/module_installer.sh'

chmod a+x module_installer.sh
mv module_installer.sh $mod_id/META-INF/com/google/android/update-binary

# GENERATING UPDATER SCRIPT

echo '[*] Generating updater script...'
echo '#MAGISK' > $mod_id/META-INF/com/google/android/updater-script

# GENERATING CUSTOM SCRIPT

echo '[*] Generating custom script...'

for i in $mod_id/system/fonts/*.ttf; do
	echo "set_perm /data/adb/modules/$mod_id/system/fonts/$i root root 644" >> $mod_id/customize.sh
done

# ARCHIVING THE MODULE

echo '[*] Zipping the module...
'

cd $mod_id
zip -r ../$mod_id.zip *
cd -

echo "
Done! Here's your file tree. File has been saved as: '$mod_id.zip'.
"

tree $mod_id
rm -rf $mod_id
