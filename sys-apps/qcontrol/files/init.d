#!/sbin/openrc-run
# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

pidfile="/run/qcontrol.pid"

depend() {
	after local
}

start() {
	if [ ! -f "/etc/qcontrol.conf" ] ; then
		eerror "Provide a proper qcontrol.conf device configuration file!"
		return 1
	fi
	start-stop-daemon --start --background --pidfile ${pidfile} --make-pidfile --exec /usr/sbin/qcontrol -- -f
}

stop() {
	start-stop-daemon --stop --pidfile ${pidfile} --name qcontrol
	rm -rf /run/qcontrol.sock
}
