#!@RCD_SCRIPTS_SHELL@
#
# $NetBSD: dk-milter.sh,v 1.2 2005/07/20 19:51:10 tv Exp $
#
# PROVIDE: dkmilter
# REQUIRE: DAEMON

if [ -f /etc/rc.subr ]; then
	. /etc/rc.subr
fi

name="dkmilter"
rcvar=$name
command="@PREFIX@/sbin/dk-milter"
pidfile="/var/run/${name}.pid"
command_args="-hl -P ${pidfile} -p ${dkmilter_socket-local:/tmp/.dkmilter.sock}"

if [ -f /etc/rc.subr ]; then
        load_rc_config $name
	run_rc_command "$1"
else
	echo -n " ${name}"
	${command} ${dkmilter_flags} ${command_args}
fi
