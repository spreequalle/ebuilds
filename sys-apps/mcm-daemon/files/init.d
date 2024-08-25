#!/sbin/openrc-run
# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

pidfile="/run/mcm-daemon.pid"

depend() {
	after local
}

start() {
	if [ ! -f "/etc/mcm-daemon.ini" ] ; then
		eerror "Provide a proper mcm-daemon.ini configuration file!"
		return 1
	fi
	start-stop-daemon --start --background --pidfile ${pidfile} --make-pidfile --exec /usr/sbin/mcm-daemon -- -f
}

stop() {
	start-stop-daemon --stop --pidfile ${pidfile} --name mcm-daemon
}
