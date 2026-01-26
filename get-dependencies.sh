#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
  libcups       \
  libdrm        \
  libnotify     \
  libpulse      \
  libxcb        \
  libxcomposite \
  libxdamage    \
  libxext       \
  libxfixes     \
  libxrandr

if [ "$ARCH" = 'x86_64' ]; then
	sudo pacman -S --noconfirm libva-intel-driver
fi

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano intel-media-driver-mini

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# get latest deb directly from upstream
latest_ver=$(
	wget https://updates.signal.org/desktop/apt/dists/xenial/main/binary-amd64/Packages.gz -O - \
	| zcat | grep -v beta | awk -F'/' '/Filename: /{print $NF; exit}' | awk -F'_' '{print $(NF-1)}'
)

if [ -z "$latest_ver" ]; then
	>&2 echo "Something went wrong getting latest version"
	exit 1
fi

case "$ARCH" in
	x86_64)  debarch=amd64;;
	aarch64) debarch=arm64;;
esac

DEB_LINK=https://updates.signal.org/desktop/apt/pool/s/signal-desktop/signal-desktop_"$latest_ver"_"$debarch".deb
wget "$DEB_LINK" -O /tmp/temp.deb
ar x /tmp/temp.deb
tar xvf ./data.tar.xz
mkdir -p ./AppDir/bin
mv -v ./opt/* ./AppDir/bin
cp -v ./usr/share/icons/hicolor/256x256/apps/signal-desktop.png ./AppDir
cp -v ./usr/share/icons/hicolor/256x256/apps/signal-desktop.png ./.DirIcon

echo "$latest_ver" > ~/version
