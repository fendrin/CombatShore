#!/bin/bash
# Copyright (C) 2022 by Fabian Mueller <fendrin@gmx.de>
# SPDX-License-Identifier: GPL-2.0+


game_name="CombatShore"
game_ver="v0.0.0"
lovr_ver="v0.16.0"
yue_ver="v0.15.14"
content_path="game"


############################

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TOPLEVEL=${DIR}/../..
create_dir=${DIR}/builds
resources_dir=${DIR}/resources
tmp_dir=/tmp/${game_name}_distribution
yue_dir=${resources_dir}/Yuescript

lovr_url=https://github.com/bjornbytes/lovr/releases/download/${lovr_ver}
yue_url=https://github.com/pigpigyyy/Yuescript/releases/download/${yue_ver}

rm -r $tmp_dir $create_dir
mkdir -p $tmp_dir $create_dir


####################### .lovr file

lovr_dir=${resources_dir}/lovr
lovr_path=${create_dir}/${game_name}.lovr

echo "Building ${lovr_path}"
cd ${TOPLEVEL}/${content_path}
zip -9qx "*.git*" -r $lovr_path .


####################### Debian Package

# deb_dir=${create_dir}/debian

# if command -v dpkg-buildpackage &> /dev/null
# then
#     cd $DIR
#     dpkg-buildpackage -us -uc
#     mkdir -p $deb_dir
#     mv ${DIR}/../${game_name}*.deb $deb_dir
# fi


########## Android APK

apk_zip=lovr-${lovr_ver}.apk.zip
apk_dir=${tmp_dir}/android
apk_path=${apk_dir}/unpacked

## fetch and unpack lovr for android
wget -nc -P $lovr_dir ${lovr_url}/${apk_zip}
unzip -n -q -d $apk_dir ${lovr_dir}/${apk_zip}
unzip -n -q -d $apk_path ${apk_dir}/lovr.apk

cd ${apk_path}
mkdir ./assets
# TODO check if this works, don't know if a .lovr file works here
cp ${lovr_path} ./assets

# TODO sign and repack the APK


########## Linux AppImage

## fetch and unpack lovr for linux
lnx_ai=lovr-${lovr_ver}-x86_64.AppImage
lnx_dir=${tmp_dir}/linux
app_name=${game_name}-x86_64.AppImage

wget -nc -P $lovr_dir ${lovr_url}/${lnx_ai}
chmod 770 ${lovr_dir}/${lnx_ai}
mkdir -p $lnx_dir
cd $lnx_dir
${lovr_dir}/${lnx_ai} --appimage-extract
cd squashfs-root

## fuse the lovr zip with the lovr binary
cat ./lovr ${lovr_path} > ${game_name}
chmod 770 ${game_name}
rm ./lovr ./lovr.desktop

# TODO take care of yue.so

## setup the directory
mv LÖVR-x86_64.AppImage ${app_name}

echo "#!/bin/sh

IMAGE_DIR=\"\$(dirname \"\$(readlink -f \"\$0\")\")\"

exec \"\$IMAGE_DIR/${game_name}\" \"\$@\"
" > ./AppRun

echo "[Desktop Entry]
Exec=AppRun
Name=${game_name}
Type=Application
Icon=logo
Categories=Game;
" > ./${game_name}.desktop

cd ..
appimagetool-x86_64.AppImage -v ./squashfs-root

mv ./${app_name} ${create_dir}


#################### Windows

win_dir=${tmp_dir}/win64/${game_name}_${game_ver}
win_zip=lovr-${lovr_ver}-win64.zip

## fetch and unpack lovr for win64
mkdir -p $win_dir
wget -nc -P $lovr_dir ${lovr_url}/${win_zip}
unzip -n -q -d $win_dir ${lovr_dir}/${win_zip}

## fetch and unpack Yuescript for win64
wget -nc -P ${yue_dir} ${yue_url}/yue-windows-x64-lua51-dll.7z
7z x -o${win_dir} ${yue_dir}/yue-windows-x64-lua51-dll.7z

## append the lovr file to the windows binary
cat ${win_dir}/lovr.exe $lovr_path > ${win_dir}/${game_name}.exe

## setup the windows dir
rm ${win_dir}/lovr.exe ${win_dir}/lovrc.bat
# mv ${win_dir}/license.txt ${win_dir}/license_lovr.txt
cp ${TOPLEVEL}/README.md $win_dir
cp ${TOPLEVEL}/license.txt ${win_dir}/license_${game_name}.txt

## zip and self-extraction
7z a -sfx ${create_dir}/${game_name}-win64.exe ${win_dir}
7z a      ${create_dir}/${game_name}-win64.7z  ${win_dir}


################ MacOS

## fetch and unpack lovr for macosx
# mac_dir=${tmp_dir}/macOSX
# mac_7z=lovr-${lovr_ver}-macOS.dmg
# wget -nc -P $lovr_dir ${lovr_url}/${mac_7z}
# 7z x -o${mac_dir} ${lovr_dir}/${mac_7z}

## fetch and unpack Yuescript for macosx
# yue_mac=${yue_url}/yue-macos-universal-luajit-so.zip
# wget -nc -P $yue_dir $yue_mac
# unzip -n -q -d ${mac_dir}/LÖVR.app/Contents/Resources $yue_mac

## copy the lovr file
# cp $lovr_path ${mac_dir}/Contents/Resources

# cp ${utils_dir}/macos/Info.plist ${mac_dir}/Contents/Info.plist

# ## move the dir to destination
# rm -rf ${mac_dir}/${game_name}-lovr-${game_ver}.app
# mkdir -p $mac_dir
# mv $mac_dir ${mac_dir}/${game_name}-lovr-${game_ver}.app

# ## zip and prepare for self-extraction
# cd $mac_dir
# zip -q -9 -r -y ${game_name}-lovr-macos.zip ${game_name}-lovr-${game_ver}.app
# cat ${zipsfx_dir}/unzipsfx ${game_name}-lovr-macos.zip > ${game_name}-lovr-macos.exe
# zip -A ${game_name}-lovr-macos.exe
