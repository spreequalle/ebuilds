# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="🎧☁️ Your Personal Streaming Service"
HOMEPAGE="https://www.navidrome.org/"

SRC_URI="
	https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${PN}-v${PV}.tar.gz
	https://github.com/spreequalle/ebuilds/releases/download/media-sound/navidrome/navidrome-v${PV}-godeps.tar.xz
	https://github.com/spreequalle/ebuilds/releases/download/media-sound/navidrome/navidrome-v${PV}-jsdeps.tar.xz
"

ND_GIT_SHA="beb768c"
ND_GIT_TAG="${PV}"

KEYWORDS="amd64 arm arm64 x86 ~arm64-macos ~x64-macos"

IUSE="mpv systemd"
LICENSE="GPL-3"
SLOT="0"

RDEPEND="
	acct-user/navidrome
	dev-db/sqlite
	media-libs/taglib
	media-video/ffmpeg
	mpv? ( media-video/mpv )
"
BDEPEND="
	acct-user/navidrome
	>=dev-lang/go-1.22.0
	>=net-libs/nodejs-20.0.0[npm]
"

src_prepare() {
	# provide frontend deps
	ln -sr "${WORKDIR}"/node_modules ui

	# sanity checks
	make check_go_env || die "Error validating golang environment!"
	make check_node_env || die "Error validating nodejs environment!"

	default
}

src_compile() {
	# frontend
	make buildjs || die "Failed to build Frontend"

	# backend
	ego build -ldflags="-X github.com/navidrome/navidrome/consts.gitSha=${ND_GIT_SHA} -X github.com/navidrome/navidrome/consts.gitTag=${ND_GIT_TAG} -s -w" \
	-tags="netgo" || die "Failed to build Backend"
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
