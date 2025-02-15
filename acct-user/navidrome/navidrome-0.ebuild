# Copyright 2025 Erik Hoppe <generik@spreequalle.de>
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="A user for media-sound/navidrome"

ACCT_USER_GROUPS=("navidrome")
ACCT_USER_HOME="/var/lib/navidrome/"
ACCT_USER_ID="136"

acct-user_add_deps
