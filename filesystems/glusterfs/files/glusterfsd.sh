#!/bin/sh
#
# $NetBSD: glusterfsd.sh,v 1.1 2011/04/18 16:19:48 manu Exp $
#

# PROVIDE: glusterfsd
# REQUIRE: rpcbind

$_rc_subr_loaded . /etc/rc.subr

name="glusterfsd"
rcvar=$name
command="@PREFIX@/sbin/${name}"
pidfile="/var/run/${name}.pid"
required_files="@PREFIX@/etc/glusterfs/${name}.vol"

load_rc_config $name
run_rc_command "$1"
