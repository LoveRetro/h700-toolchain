#! /bin/bash

set -euo pipefail

# H700 mali-fbdev SDL2 (JohnnyonFlame/SDL-malifbdev-rot), pinned + NextUI joystick patch.
# Installs into PREFIX_LOCAL so NextUI can link/package without rebuilding.
#
# Keep in sync with NextUI workspace/h700/patches/sdl2-h700.patch and the former
# early-target configure flags in workspace/h700/makefile.

SDL2_COMMIT=d4a7d7503524cc469fe775242f3f925d4dd56c88
SDL2_SRC=/tmp/sdl2-h700

: "${CROSS_TRIPLE:?CROSS_TRIPLE is required}"
: "${PREFIX_LOCAL:?PREFIX_LOCAL is required}"

rm -rf "$SDL2_SRC"
git clone https://github.com/JohnnyonFlame/SDL-malifbdev-rot.git "$SDL2_SRC"
cd "$SDL2_SRC"
git checkout "$SDL2_COMMIT"
git apply /root/support/sdl2-h700.patch

if [ ! -f configure ]; then
	./autogen.sh
fi

./configure \
	--host="$CROSS_TRIPLE" \
	--prefix="$PREFIX_LOCAL" \
	--enable-video-mali \
	--enable-alsa \
	--enable-alsa-shared \
	--enable-video-opengles \
	--disable-video-opengl \
	--disable-video-x11 \
	--disable-video-wayland \
	--disable-video-kmsdrm \
	--disable-pulseaudio \
	--disable-jack \
	--disable-esd \
	--disable-arts \
	--disable-nas \
	--disable-sndio \
	--disable-dbus \
	--disable-ibus \
	--disable-fcitx \
	--disable-hidapi \
	--disable-libudev \
	--disable-power \
	--enable-filesystem \
	--disable-sensor \
	--disable-locale \
	--enable-loadso \
	--enable-shared \
	--disable-static \
	--disable-libsamplerate-shared

grep -q '^#define SDL_VIDEO_DRIVER_MALI 1' include/SDL_config.h

make -j"$(nproc)"
make install

mkdir -p "$PREFIX_LOCAL/share"
echo "$SDL2_COMMIT" > "$PREFIX_LOCAL/share/h700-sdl2-commit"

cd /tmp
rm -rf "$SDL2_SRC"
