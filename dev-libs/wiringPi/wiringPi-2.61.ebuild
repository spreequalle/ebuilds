# Copyright 1999-2022 Erik Hoppe
# Distributed under the terms of the GNU LGPL-3.0 license
# $Header: $

EAPI="8"

MY_P=WiringPi-${PV}-1
DESCRIPTION="GPIO Interface library for the Raspberry Pi"
HOMEPAGE="http://wiringpi.com/"
SRC_URI="https://github.com/${PN}/${PN}/archive/refs/tags/${PV}-1.tar.gz -> ${P}-1.tar.gz"
S=${WORKDIR}/${MY_P}/${PN}

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 arm arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE=""

RDEPEND="virtual/libcrypt"
DEPEND="${RDEPEND}"

src_prepare() {
	# fix absolute symlink
	sed -i -e "s|\(ln -sf\)|\\1r|g" Makefile
	# patch hardcoded libdir
	sed -i -e "s|/lib\(/\?\)|/$(get_libdir)\\1|g" Makefile
	# prefix header directory
	sed -i -e "s|\(/include\)|\\1/wiringPi|g" Makefile

	default
}

src_compile() {
	# honor upstream cflags
	emake EXTRA_CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
}

src_install() {
	emake LDFLAGS="${LDFLAGS}" DESTDIR="${D}/usr/" PREFIX="" install
}
