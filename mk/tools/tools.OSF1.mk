# $NetBSD: tools.OSF1.mk,v 1.6 2005/05/04 06:42:43 jlam Exp $
#
# System-supplied tools for the OSF/1 operating system.

TOOLS_PLATFORM.[?=		[			# shell builtin
TOOLS_PLATFORM.awk?=		/usr/bin/awk
TOOLS_PLATFORM.basename?=	/usr/bin/basename
TOOLS_PLATFORM.cat?=		/bin/cat
TOOLS_PLATFORM.chgrp?=		/usr/bin/chgrp
TOOLS_PLATFORM.chmod?=		/bin/chmod
TOOLS_PLATFORM.chown?=		/bin/chown
TOOLS_PLATFORM.cmp?=		/usr/bin/cmp
TOOLS_PLATFORM.cp?=		/bin/cp
TOOLS_PLATFORM.cut?=		/usr/bin/cut
TOOLS_PLATFORM.date?=		/bin/date
TOOLS_PLATFORM.dirname?=	/usr/bin/dirname
TOOLS_PLATFORM.echo?=		/usr/bin/echo
TOOLS_PLATFORM.egrep?=		/usr/bin/grep -E
TOOLS_PLATFORM.env?=		/usr/bin/env
TOOLS_PLATFORM.expr?=		/bin/expr
TOOLS_PLATFORM.false?=		false			# shell builtin
TOOLS_PLATFORM.fgrep?=		/usr/bin/grep -F
TOOLS_PLATFORM.file?=		/usr/bin/file
TOOLS_PLATFORM.find?=		/usr/bin/find
TOOLS_PLATFORM.grep?=		/usr/bin/grep
TOOLS_PLATFORM.gunzip?=		/usr/bin/gunzip -f
TOOLS_PLATFORM.gzcat?=		/usr/bin/gzcat
TOOLS_PLATFORM.gzip?=		/usr/bin/gzip -nf ${GZIP}
TOOLS_PLATFORM.head?=		/usr/bin/head
TOOLS_PLATFORM.hostname?=	/bin/hostname
TOOLS_PLATFORM.id?=		/usr/bin/id
TOOLS_PLATFORM.ldconfig?=	${TOOLS_PLATFORM.true}
TOOLS_PLATFORM.ln?=		/bin/ln
TOOLS_PLATFORM.ls?=		/bin/ls
TOOLS_PLATFORM.m4?=		/usr/bin/m4
TOOLS_PLATFORM.mail?=		/usr/bin/mailx
TOOLS_PLATFORM.mkdir?=		/bin/mkdir -p
TOOLS_PLATFORM.mv?=		/bin/mv
TOOLS_PLATFORM.nice?=		/usr/bin/nice
TOOLS_PLATFORM.pwd?=		/bin/pwd
TOOLS_PLATFORM.rm?=		/bin/rm
TOOLS_PLATFORM.rmdir?=		/bin/rmdir
TOOLS_PLATFORM.sh?=		/bin/ksh
TOOLS_PLATFORM.sort?=		/usr/bin/sort
TOOLS_PLATFORM.strip?=		\
	${_INSTALL_UNSTRIPPED:D${TOOLS_PLATFORM.true}:U/usr/ccs/bin/strip}
TOOLS_PLATFORM.tail?=		/usr/bin/tail
TOOLS_PLATFORM.tee?=		/usr/bin/tee
TOOLS_PLATFORM.test?=		test			# shell builtin
TOOLS_PLATFORM.touch?=		/usr/bin/touch
TOOLS_PLATFORM.tr?=		/usr/bin/tr
TOOLS_PLATFORM.true?=		true			# shell builtin
TOOLS_PLATFORM.tsort?=		/usr/bin/tsort
TOOLS_PLATFORM.wc?=		/usr/bin/wc
TOOLS_PLATFORM.xargs?=		/usr/bin/xargs
