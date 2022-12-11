#!/bin/bash
# Copyright (C) 2022 by Fabian Mueller <fendrin@gmx.de>
# SPDX-License-Identifier: GPL-2.0+


game_name="CombatShore"
deb_name="combatshore"
game_ver="0.0.0"
lovr_ver="0.16.0"
yue_ver="0.15.14"
content_path="game"
author="Fabian Mueller <fendrin@gmx.de>"
description="A game of ice and fire"
homepage="https://github.com/fendrin/CombatShore"
vcs_git="https://github.com/fendrin/CombatShore.git"
vcs_browser="https://github.com/fendrin/CombatShore"


#######################

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TOPLEVEL=${DIR}/../..
create_dir=${DIR}/builds
resources_dir=${DIR}/resources
tmp_dir=/tmp/${game_name}_distribution
yue_dir=${resources_dir}/Yuescript

lovr_url=https://github.com/bjornbytes/lovr/releases/download/v${lovr_ver}
yue_url=https://github.com/pigpigyyy/Yuescript/releases/download/v${yue_ver}

rm -r $tmp_dir $create_dir
mkdir -p $tmp_dir $create_dir


####################### .lovr file

lovr_dir=${resources_dir}/lovr
lovr_path=${create_dir}/${game_name}-${game_ver}.lovr

echo "Building ${lovr_path}"
cd ${TOPLEVEL}/${content_path}
zip -9qx "*.git*" -r $lovr_path .


####################### Debian Package

deb_dir=${tmp_dir}/debian

rm -r ${deb_dir}
mkdir -p ${deb_dir}/scripts ${deb_dir}/source

cp ${lovr_path} ${tmp_dir}
cp ${TOPLEVEL}/changelog ${deb_dir}

echo "3.0 (native)
" > ${deb_dir}/source/format

echo "10
" > ${deb_dir}/compat

# Version: ${game_ver}
# Uploaders: $author
# Vcs-Git: ${vcs_git}
# Vcs-Browser: ${vcs_browser}
echo "Source: ${deb_name}
Section: games
Priority: extra
Maintainer: $author
Standards-Version: 4.5.1
Rules-Requires-Root: no

Package: ${deb_name}
Architecture: all
Homepage: ${homepage}
Depends: lovr (>=${lovr_ver})
Description: ${description}
" > ${deb_dir}/control

echo "[Desktop Entry]
Name=${game_name}
Comment=${description}
Exec=/usr/games/${game_name}
Terminal=false
Type=Application
Categories=Games;
" > ${deb_dir}/${deb_name}.desktop

echo "#!/usr/bin/make -f
%:
	dh \$@
" > ${deb_dir}/rules
chmod 770 ${deb_dir}/rules

echo "debian/scripts/${game_name} usr/games
debian/${deb_name}.desktop usr/share/applications
${game_name}-${game_ver}.lovr usr/share/games/${deb_name}
" > ${deb_dir}/${deb_name}.install

echo "#!/bin/sh
exec lovr /usr/share/games/${deb_name}/${game_name}-${game_ver}.lovr \"\$@\"
" > ${deb_dir}/scripts/${game_name}

if command -v dpkg-buildpackage &> /dev/null 
then
  cd $tmp_dir
  dpkg-buildpackage -us -uc
  mkdir -p $create_dir/deb
  mv /tmp/${deb_name}* $create_dir/deb
fi


##################### Android APK

apk_zip=lovr-v${lovr_ver}.apk.zip
apk_dir=${tmp_dir}/android
apk_path=${apk_dir}/unpacked

## fetch and unpack lovr for android
wget -nc -P $lovr_dir ${lovr_url}/${apk_zip}
unzip -n -q -d $apk_dir ${lovr_dir}/${apk_zip}
unzip -n -q -d $apk_path ${apk_dir}/lovr.apk

## deploy the content
cd ${apk_path}
mkdir ./assets
unzip -n -q -d ./assets ${lovr_path}

## deploy Yuescript
cp ${yue_dir}/yue_arm.so ./lib/arm64-v8a/yue.so

# TODO sign the APK
zip -q -9 -r -y ${create_dir}/${game_name}-${game_ver}.apk *


########## Linux AppImage

AIT_name=appimagetool-x86_64.AppImage
AIT_path=${resources_dir}/${AIT_name}
AIT_url=https://github.com/AppImage/AppImageKit/releases/download/13/${AIT_name}
lnx_ai=lovr-v${lovr_ver}-x86_64.AppImage
lnx_dir=${tmp_dir}/linux
app_name=${game_name}-v${game_ver}-x86_64.AppImage

## fetch and unpack lovr for linux
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

# TODO take care of fetching yue.so
cp ${yue_dir}/yue.so ./

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

wget -nc -P $resources_dir $AIT_url
chmod 770 $AIT_path 

cd ..
$AIT_path -v ./squashfs-root
mv ./${game_name}-x86_64.AppImage ${create_dir}/${app_name}


#################### Windows

win_dir=${tmp_dir}/win64/${game_name}_${game_ver}
win_zip=lovr-v${lovr_ver}-win64.zip
win_name=${game_name}-${game_ver}-win64

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
7z a -sfx ${create_dir}/${win_name}.exe ${win_dir}
7z a      ${create_dir}/${win_name}.7z  ${win_dir}


################ MacOS

# mac_dir=${tmp_dir}/macOSX
# mac_zip=lovr-${lovr_ver}-macOS.zip
# yue_mac=${yue_url}/yue-macos-universal-luajit-so.zip

# ## fetch and unpack lovr for macosx
# wget -nc -P $lovr_dir ${lovr_url}/${mac_zip}
# unzip -n -q -d ${mac_dir} ${lovr_dir}/${mac_zip}

# ## fetch and unpack Yuescript for macosx
# wget -nc -P $yue_dir $yue_mac
# unzip -n -q -d ${mac_dir}/LÖVR.app/Contents/MacOS $yue_mac

# ## copy the lovr file
# cp $lovr_path ${mac_dir}/LÖVR.app/Contents/Resources

# sed -i -- 's/LÖVR/${game_name}/g' ${mac_dir}/LÖVR.app/Contents/Info.plist
# sed -i -- 's/lovr/${game_name}/g' ${mac_dir}/LÖVR.app/Contents/Info.plist
# echo "APPL${game_name}" > ${mac_dir}/LÖVR.app/Contents/PkgInfo

# ## zip
# cd $mac_dir
# mv LÖVR.app ${game_name}.app
# zip -q -9 -r -y ${create_dir}/${game_name}-${game_ver}-macos.zip ${game_name}.app
