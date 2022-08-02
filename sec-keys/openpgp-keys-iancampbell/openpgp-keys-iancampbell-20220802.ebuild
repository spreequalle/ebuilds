# Copyright 1999-2022 Erik Hoppe
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="OpenPGP keys used by Ian Campbell"
HOMEPAGE="https://www.hellion.org.uk/"
# see https://www.hellion.org.uk/public_key.html
SRC_URI="
	https://www.hellion.org.uk/public_key.asc
		-> iancampbell-9D5CEE01334F46CE2FEF6DC6EC63699779074FA8.asc
"
S=${WORKDIR}

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"

src_install() {
	local files=( ${A} )
	insinto /usr/share/openpgp-keys
	newins - iancampbel.asc < <(cat "${files[@]/#/${DISTDIR}/}" || die)
}
