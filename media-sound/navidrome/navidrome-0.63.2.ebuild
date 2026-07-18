# Copyright 2026 <generik@spreequalle.de>
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd tmpfiles toolchain-funcs

DESCRIPTION="🎧☁️ Your Personal Streaming Service"
HOMEPAGE="https://www.navidrome.org/"

SRC_URI="
	https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${PN}-v${PV}.tar.gz
	https://github.com/spreequalle/ebuilds/releases/download/media-sound/navidrome/navidrome-v${PV}-godeps.tar.xz
	https://github.com/spreequalle/ebuilds/releases/download/media-sound/navidrome/navidrome-v${PV}-jsdeps.tar.xz
"

ND_GIT_SHA="be10f89"
ND_GIT_TAG="${PV}"

KEYWORDS="amd64 arm arm64 x86 ~arm64-macos ~x64-macos"

IUSE="mpv static systemd"
LICENSE="GPL-3"
SLOT="0"

RDEPEND="
	acct-user/navidrome
	dev-db/sqlite
	media-libs/libwebp
	media-video/ffmpeg
	mpv? ( media-video/mpv )
"
BDEPEND="
	acct-user/navidrome
	>=dev-lang/go-1.26
	static? ( arm? ( elibc_glibc? ( llvm-core/lld ) ) )
	>=net-libs/nodejs-24.0.0[npm]
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
	GO_LDFLAGS="-X github.com/navidrome/navidrome/consts.gitSha=${ND_GIT_SHA} -X github.com/navidrome/navidrome/consts.gitTag=${ND_GIT_TAG}"
	GO_TAGS="netgo,sqlite_fts5"

	if use static; then
		GO_LDFLAGS="${GO_LDFLAGS} -linkmode=external -extldflags '-static'"

		# required on 32-bit arm (arm/v6, arm/v7) so SQLite's 64-bit atomics resolve
		if use arm && tc-is-gcc; then
			GO_LDFLAGS="${GO_LDFLAGS} '-latomic'"
		fi

		# GNU ld corrupts the R_ARM_IRELATIVE addends of libatomic's ifunc resolvers
		# (wrong address, Thumb bit lost) once .text outgrows the 16MB Thumb branch
		# range, making static arm binaries jump to garbage inside glibc's ifunc
		# resolution and crash before main() (issue #5738). Link 32-bit arm with LLD,
		# which emits correct addends.
		if use arm && use elibc_glibc; then
			GO_LDFLAGS="${GO_LDFLAGS} '-fuse-ld=lld'"
		fi
	fi

	# prevent go native libwebp (gen2brain/webp) related crashes: https://github.com/navidrome/navidrome/issues/5597
	if use arm || use x86; then
		GO_TAGS="${GO_TAGS},nodynamic"
	fi


	ego build -ldflags="${GO_LDFLAGS}" -tags="${GO_TAGS}" || die "Failed to build Backend"
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

	newtmpfiles "${FILESDIR}"/${PN}.tmpfile ${PN}.conf
}

pkg_postinst() {
	tmpfiles_process ${PN}.conf
}
