# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

LUA_COMPAT=( lua5-1 luajit )

inherit lua-single systemd toolchain-funcs

DESCRIPTION="Qcontrol is a daemon and command line tool which controls the various peripherals that are present on many embedded NAS devices."
HOMEPAGE="https://www.hellion.org.uk/qcontrol/"
SRC_URI="https://www.hellion.org.uk/qcontrol/releases/${PV}/${P}.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="arm"
IUSE="systemd"

REQUIRED_USE="${LUA_REQUIRED_USE}"

DEPEND="${LUA_DEPS}"
RDEPEND="${DEPEND}"

src_install() {
	dosbin qcontrol

	insinto /etc/qcontrol
	doins examples/*.lua

	newinitd "${FILESDIR}"/init.d qcontrol

	if use systemd; then
		systemd_dounit systemd/qcontrol.service
		systemd_dounit systemd/qcontrold.{service,socket}
	fi
}

pkg_preinst() {
	ewarn "Checkout /etc/qcontrol/ for example configurations."
	ewarn "Setup a symlink to /etc/qcontrol.conf like shown below."
	ewarn "$ ln -sfr /etc/qcontrol/ts219.lua /etc/qcontrol.conf"
}
