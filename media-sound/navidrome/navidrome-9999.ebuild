# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 systemd

DESCRIPTION="🎧☁️ Your Personal Streaming Service"
HOMEPAGE="https://www.navidrome.org/"

EGIT_REPO_URI="https://github.com/navidrome/navidrome.git"
RESTRICT="network-sandbox"

IUSE="systemd"
LICENSE="GPL-3"
SLOT="0"

RDEPEND="
	acct-user/navidrome
	media-libs/taglib
	media-video/ffmpeg
"
BDEPEND="
	acct-user/navidrome
	>=dev-lang/go-1.22.0
	>=net-libs/nodejs-20.0.0[npm]
"

src_prepare() {
	make setup || die "Failed to setup build environment"
}

src_compile() {
	make build || die "Failed to build"
}

src_install() {
	dobin navidrome
	dodoc README.md

	insinto /var/lib/navidrome
	keepdir /var/lib/navidrome
	fowners -R navidrome:navidrome /var/lib/navidrome
	fperms 0750 /var/lib/navidrome

	insinto /etc/navidrome
	doins release/linux/navidrome.toml
	fowners navidrome:navidrome /etc/navidrome /etc/navidrome/navidrome.toml
	fperms 0750 /etc/navidrome
	fperms 0640 /etc/navidrome/navidrome.toml

	if use systemd; then
		systemd_dounit contrib/navidrome.service
	else
		keepdir /var/log/navidrome
		fowners navidrome:navidrome /var/log/navidrome
		fperms 0750 /var/log/navidrome

		newinitd "${FILESDIR}"/navidrome.initd navidrome
	fi
}
