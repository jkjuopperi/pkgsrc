#!/bin/sh
#
# $FreeBSD: ports/net/dtcpclient/files/dtcpclient.sh,v 1.5 2004/06/11 15:49:48 ume Exp $
# $NetBSD: dtcpclient.sh,v 1.1.1.1 2005/01/23 05:07:43 hamajima Exp $
#

# PROVIDE: dtcpclient
# REQUIRE: DAEMON
# BEFORE: LOGIN
# KEYWORD: shutdown
#
# NOTE for FreeBSD 5.0+:
# If you want this script to start with the base rc scripts
# move dtcpclient.sh to /etc/rc.d/dtcpclient

prefix=@PREFIX@

# Define these dtcpclient_* variables in one of these files:
#	/etc/rc.conf
#	/etc/rc.conf.local
#	/etc/rc.conf.d/dtcpclient
#
# DO NOT CHANGE THESE DEFAULT VALUES HERE
#
#dtcpclient_enable=${dtcpclient_enable:-"NO"}	# Enable dtcpclient
#dtcpclient_program="${prefix}/sbin/dtcpclient"	# Location of dtcpclient
dtcpclient_server=${dtcpclient_server:-""}	# DTCP server name
dtcpclient_username=${dtcpclient_username:-""}	# DTCP user name
dtcpclient_flags=${dtcpclient_flags:-"-t network -Dl"}	# Flags to dtcpclient program

. /etc/rc.subr

name="dtcpclient"
rcvar=`set_rcvar`
command="${prefix}/sbin/${name}"
pidfile="/var/run/${name}.pid"
extra_commands="reload"

load_rc_config $name
command_args="-u ${dtcpclient_username} ${dtcpclient_server}"
run_rc_command "$1"
