# Copyright 2024 Erik Hoppe <generik@spreequalle.de>
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit git-r3 systemd

EGIT_REPO_URI="https://github.com/cschil/mcm-deamon"

DESCRIPTION="A simple daemon for the WD-My Cloud Mirror gen2 and Ex2 ultra NAS system."
HOMEPAGE="https://github.com/cschil/mcm-deamon"

KEYWORDS="arm"

LICENSE="GPL-2"
IUSE="systemd"
SLOT=0

RDEPEND="dev-libs/iniparser"
DEPEND="${RDEPEND}"

src_prepare() {
	eapply "${FILESDIR}"/external-iniparser.patch
	eapply_user

	if use !systemd; then
		sed -i '/mcm-daemon.service/d' Makefile
	fi
}

src_install() {

	if use systemd; then
		systemd_dounit mcm-daemon.service
	else
		newinitd "${FILESDIR}"/init.d mcm-daemon
	fi
	default
}
