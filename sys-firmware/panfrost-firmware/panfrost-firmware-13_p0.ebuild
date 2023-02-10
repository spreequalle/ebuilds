# Copyright 2023 Erik Hoppe <generik@spreequalle.de>
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT=3d4d26fb997fa9acbe0aab54e819baa7161d94d9
ARM_PATCH_VER=${PV#*_p}
MY_VER=${PV%_p*}
DDK_VER=g${MY_VER}p${ARM_PATCH_VER}-01eac0

DESCRIPTION="Firmware for ARM Valhall G610 GPU's CSF MCU"
HOMEPAGE="https://gitlab.com/rk3588_linux/linux/libmali/"
SRC_URI="https://gitlab.com/rk3588_linux/linux/libmali/-/raw/${COMMIT}/firmware/g610/mali_csffw.bin -> mali_csffw_${DDK_VER}.bin"

LICENSE="ARM-MALI-EULA"
SLOT="0"
KEYWORDS="arm64"

S="${WORKDIR}"

src_unpack() {
	cp -L "${DISTDIR}"/mali_csffw_${DDK_VER}.bin "${WORKDIR}"/mali_csffw.bin
	chmod 0644 mali_csffw.bin
}

src_install() {
	insinto /lib/firmware
	doins mali_csffw.bin
}
