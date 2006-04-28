#!@RCD_SCRIPTS_SHELL@
#
# $NetBSD: courierpop.sh,v 1.12 2006/04/28 18:15:20 jlam Exp $
#
# Courier POP3 services daemon
#
# PROVIDE: courierpop
# REQUIRE: authdaemond
# KEYWORD: shutdown

. /etc/rc.subr

name="courierpop"
rcvar=${name}
command="@PREFIX@/sbin/couriertcpd"
ctl_command="@PREFIX@/sbin/pop3d"
pidfile="@VARBASE@/run/pop3d.pid"
required_files="@PKG_SYSCONFDIR@/pop3d @PKG_SYSCONFDIR@/pop3d-ssl"

start_cmd="courier_doit start"
stop_cmd="courier_doit stop"

courier_doit()
{
	action=$1
	case $action in
	start)
		for f in $required_files; do
			if [ ! -r "$f" ]; then
				@ECHO@ 1>&2 "$0: WARNING: $f is not readable"
				return 1
			fi
		done

		. @PKG_SYSCONFDIR@/pop3d

		case x$POP3DSTART in
		x[yY]*)
			@ECHO@ "Starting ${name}."
			${ctl_command} $action
                ;;
		esac
		;;
	stop)
		@ECHO@ "Stopping ${name}."
		${ctl_command} $action
		;;
	esac
}

load_rc_config $name
run_rc_command "$1"
