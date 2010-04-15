#!@RCD_SCRIPTS_SHELL@
#
# $NetBSD: c2s.sh,v 1.3 2010/04/15 07:01:23 adam Exp $
#
# PROVIDE: c2s
# REQUIRE: DAEMON

if [ -f /etc/rc.subr ]; then
	. /etc/rc.subr
fi

name="c2s"
rcvar=$name
command="@PREFIX@/bin/${name}"
required_files="@PKG_SYSCONFDIR@/${name}.xml"
extra_commands="reload"
command_args="2>&1 >/dev/null &"
c2s_user="@JABBERD_USER@"
pidfile="@JABBERD_PIDDIR@/${name}.pid"
stop_postcmd="remove_pidfile"
start_precmd="ensure_piddir"

ensure_piddir()
{
	mkdir -p @JABBERD_PIDDIR@
	chown @JABBERD_USER@ @JABBERD_PIDDIR@
}

remove_pidfile()
{
	if [ -f @JABBERD_PIDDIR@/${name}.pid ]; then
	    rm -f @JABBERD_PIDDIR@/${name}.pid
	fi
}

limits_precmd()
{
	ulimit -n 1024
}

if [ -f /etc/rc.subr ]; then
	load_rc_config $name
	run_rc_command "$1"
else
	@ECHO@ -n " ${name}"
	${command} ${c2s_flags} ${command_args}
fi
