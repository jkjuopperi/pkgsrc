# $NetBSD: bsd.pkginstall.mk,v 1.39 2006/03/10 23:36:08 jlam Exp $
#
# This Makefile fragment is included by bsd.pkg.mk and implements the
# common INSTALL/DEINSTALL scripts framework.  To use the pkginstall
# framework, simply set the relevant variables to customize the install
# scripts to the package.
#

# _PKGINSTALL_VARS is a list of the variables that, if non-empty, indicate
#	that the pkginstall framework should be used.  These variables
#	should be extracted from bsd.pkginstall.mk and are typically the
#	variables named in the _INSTALL_<SCRIPT>_MEMBERS lists.
#
# USE_PKGINSTALL may be set to "yes" to force the pkginstall framework
#	to be used.
#
_PKGINSTALL_VARS+=	HEADER_EXTRA_TMPL
_PKGINSTALL_VARS+=	DEINSTALL_EXTRA_TMPL
_PKGINSTALL_VARS+=	INSTALL_EXTRA_TMPL
_PKGINSTALL_VARS+=	DEINSTALL_SRC INSTALL_SRC

_PKGINSTALL_VARS+=	PKG_GROUPS PKG_USERS
_PKGINSTALL_VARS+=	SPECIAL_PERMS
_PKGINSTALL_VARS+=	CONF_FILES CONF_FILES_PERMS			\
			REQD_FILES REQD_FILES_PERMS			\
			RCD_SCRIPTS
_PKGINSTALL_VARS+=	INFO_FILES
_PKGINSTALL_VARS+=	MAKE_DIRS MAKE_DIRS_PERMS			\
			REQD_DIRS REQD_DIRS_PERMS			\
			OWN_DIRS OWN_DIRS_PERMS
_PKGINSTALL_VARS+=	PKG_SHELL
_PKGINSTALL_VARS+=	FONTS_DIRS.ttf FONTS_DIRS.type1 FONTS_DIRS.x11

# CONF_DEPENDS notes a dependency where the config directory for the
# package matches the dependency's config directory.  CONF_DEPENDS is
# only meaningful if PKG_INSTALLATION_TYPE is "pkgviews".
#
_PKGINSTALL_VARS+=	CONF_DEPENDS

.if defined(USE_PKGINSTALL) && !empty(USE_PKGINSTALL:M[yY][eE][sS])
_USE_PKGINSTALL=	yes
.else
_USE_PKGINSTALL=	no
.endif

.if !empty(_USE_PKGINSTALL:M[nN][oO])
.  for _var_ in ${_PKGINSTALL_VARS}
.    if defined(${_var_}) && !empty(${_var_}:M*)
_USE_PKGINSTALL=	yes
.    endif
.  endfor
.endif

# The Solaris /bin/sh does not know the ${foo#bar} shell substitution.
# This shell function serves a similar purpose, but is specialized on
# stripping ${PREFIX}/ from a pathname.
_FUNC_STRIP_PREFIX= \
	strip_prefix() {						\
	  ${AWK} 'END {							\
	    plen = length(prefix);					\
	      if (substr(s, 1, plen) == prefix) {			\
	        s = substr(s, 1 + plen, length(s) - plen);		\
	      }								\
	      print s;							\
	    }' s="$$1" prefix=${PREFIX:Q}/ /dev/null;			\
	}

# These are the template scripts for the INSTALL/DEINSTALL scripts.  Packages
# may do additional work in the INSTALL/DEINSTALL scripts by overriding the
# variables DEINSTALL_EXTRA_TMPL and INSTALL_EXTRA_TMPL to point to
# additional script fragments.  These bits are included after the main
# install/deinstall script fragments.
#
_HEADER_TMPL?=		${.CURDIR}/../../mk/install/header
.if !defined(HEADER_EXTRA_TMPL) && exists(${.CURDIR}/HEADER)
HEADER_EXTRA_TMPL?=	${.CURDIR}/HEADER
.else
HEADER_EXTRA_TMPL?=	# empty
.endif
_DEINSTALL_PRE_TMPL?=	${.CURDIR}/../../mk/install/deinstall-pre
DEINSTALL_EXTRA_TMPL?=	# empty
_DEINSTALL_TMPL?=	${.CURDIR}/../../mk/install/deinstall
_INSTALL_UNPACK_TMPL?=	# empty
_INSTALL_TMPL?=		${.CURDIR}/../../mk/install/install
INSTALL_EXTRA_TMPL?=	# empty
_INSTALL_POST_TMPL?=	${.CURDIR}/../../mk/install/install-post
_FOOTER_TMPL?=		${.CURDIR}/../../mk/install/footer

# DEINSTALL_TEMPLATES and INSTALL_TEMPLATES are the default list of source
#	files that are concatenated to form the DEINSTALL/INSTALL scripts.
#
DEINSTALL_TEMPLATES=	${_HEADER_TMPL}
DEINSTALL_TEMPLATES+=	${HEADER_EXTRA_TMPL}
DEINSTALL_TEMPLATES+=	${_DEINSTALL_PRE_TMPL}
DEINSTALL_TEMPLATES+=	${DEINSTALL_EXTRA_TMPL}
DEINSTALL_TEMPLATES+=	${_DEINSTALL_TMPL}
DEINSTALL_TEMPLATES+=	${_FOOTER_TMPL}
INSTALL_TEMPLATES=	${_HEADER_TMPL}
INSTALL_TEMPLATES+=	${HEADER_EXTRA_TMPL}
INSTALL_TEMPLATES+=	${_INSTALL_UNPACK_TMPL}
INSTALL_TEMPLATES+=	${_INSTALL_TMPL}
INSTALL_TEMPLATES+=	${INSTALL_EXTRA_TMPL}
INSTALL_TEMPLATES+=	${_INSTALL_POST_TMPL}
INSTALL_TEMPLATES+=	${_FOOTER_TMPL}

# These are the list of source files that are concatenated to form the
# INSTALL/DEINSTALL scripts.
#
DEINSTALL_SRC?=		${DEINSTALL_TEMPLATES}
INSTALL_SRC?=		${INSTALL_TEMPLATES}

# FILES_SUBST lists what to substitute in DEINSTALL/INSTALL scripts and in
# rc.d scripts.
#
FILES_SUBST+=		PREFIX=${PREFIX:Q}
FILES_SUBST+=		LOCALBASE=${LOCALBASE:Q}
FILES_SUBST+=		X11BASE=${X11BASE:Q}
FILES_SUBST+=		DEPOTBASE=${DEPOTBASE:Q}
FILES_SUBST+=		VARBASE=${VARBASE:Q}
FILES_SUBST+=		PKG_SYSCONFBASE=${PKG_SYSCONFBASE:Q}
FILES_SUBST+=		PKG_SYSCONFDEPOTBASE=${PKG_SYSCONFDEPOTBASE:Q}
FILES_SUBST+=		PKG_SYSCONFBASEDIR=${PKG_SYSCONFBASEDIR:Q}
FILES_SUBST+=		PKG_SYSCONFDIR=${PKG_SYSCONFDIR:Q}
FILES_SUBST+=		CONF_DEPENDS=${CONF_DEPENDS:C/:.*//:Q}
FILES_SUBST+=		PKGBASE=${PKGBASE:Q}
FILES_SUBST+=		PKG_INSTALLATION_TYPE=${PKG_INSTALLATION_TYPE:Q}

# PKG_USERS represents the users to create for the package.  It is a
#	space-separated list of elements of the form
#
#		user:group[:[userid][:[descr][:[home][:shell]]]]
#
#	Only the user and group are required; everything else is optional,
#	but the colons must be in the right places when specifying optional
#	bits.  Note that if the description contains spaces, they must
#	be escaped as usual, e.g.
#
#		foo:foogrp::The\ Foomister
#
# PKG_GROUPS represents the groups to create for the package.  It is a
#	space-separated list of elements of the form
#
#		group[:groupid]
#
#	Only the group is required; the groupid is optional.
#
PKG_GROUPS?=		# empty
PKG_USERS?=		# empty
_PKG_USER_HOME?=	/nonexistent
_PKG_USER_SHELL?=	${NOLOGIN}
FILES_SUBST+=		PKG_USER_HOME=${_PKG_USER_HOME:Q}
FILES_SUBST+=		PKG_USER_SHELL=${_PKG_USER_SHELL:Q}

# Interix is very special in that users are groups cannot have the
# same name.  Interix.mk tries to work around this by overriding
# some specific package defaults.  If we get here and there's still a
# conflict, add a breakage indicator to make sure the package won't
# compile without changing something.
#
.if !empty(OPSYS:MInterix)
.  for user in ${PKG_USERS:C/\\\\//g:C/:.*//}
.    if !empty(PKG_GROUPS:M${user})
PKG_FAIL_REASON+=	"User and group '${user}' cannot have the same name on Interix"
.    endif
.  endfor
.endif

.if !empty(PKG_USERS) || !empty(PKG_GROUPS)
DEPENDS+=		${_USER_DEPENDS}
.endif

_INSTALL_USERGROUP_FILE=	${WRKDIR}/.install-usergroup
.if exists(../../mk/install/usergroupfuncs.${OPSYS})
_INSTALL_USERGROUPFUNCS_FILE?=	../../mk/install/usergroupfuncs.${OPSYS}
.else
_INSTALL_USERGROUPFUNCS_FILE?=	../../mk/install/usergroupfuncs
.endif
_INSTALL_UNPACK_TMPL+=		${_INSTALL_USERGROUP_FILE}
_INSTALL_USERGROUP_MEMBERS=	${PKG_USERS} ${PKG_GROUPS}

${_INSTALL_USERGROUP_FILE}:						\
		../../mk/install/usergroup				\
		${INSTALL_USERGROUPFUNCS_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${RM} -f ${.TARGET} ${.TARGET}.tmp;				\
	exec 1>>${.TARGET}.tmp;						\
	${ECHO} "# start of install-usergroup";				\
	${ECHO} "#";							\
	${ECHO} "# Generate a +USERGROUP script that reference counts users"; \
	${ECHO} "# and groups that are required for the proper functioning"; \
	${ECHO} "# of the package.";					\
	${ECHO} "#";							\
	${ECHO} "case \$${STAGE} in";					\
	${ECHO} "PRE-INSTALL|UNPACK)";					\
	${ECHO} "	\$${CAT} > ./+USERGROUP << 'EOF_USERGROUP'";	\
	${SED}	-e "/^# platform-specific adduser\/addgroup functions/r${_INSTALL_USERGROUPFUNCS_FILE}" ../../mk/install/usergroup | \
	${SED} ${FILES_SUBST_SED};					\
	${ECHO} "";							\
	set -- dummy ${PKG_GROUPS}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		i="$$1"; shift;						\
		${ECHO} "# GROUP: $$i";					\
	done;								\
	set -- dummy ${PKG_USERS}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		i="$$1"; shift;						\
		${ECHO} "# USER: $$i";					\
	done;								\
	${ECHO} "EOF_USERGROUP";					\
	${ECHO} "	\$${CHMOD} +x ./+USERGROUP";			\
	${ECHO} "	;;";						\
	${ECHO} "esac";							\
	${ECHO} "";							\
	${ECHO} "# end of install-usergroup";				\
	exec 1>/dev/null;						\
	${MV} -f ${.TARGET}.tmp ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	set -- dummy ${_INSTALL_USERGROUP_MEMBERS}; shift;		\
	if ${TEST} $$# -eq 0; then					\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi

# SPECIAL_PERMS are lists that look like:
#		file user group mode
#	At post-install time, file (it may be a directory) is changed to be
#	owned by user:group with mode permissions.  If a file pathname
#	is relative, then it is taken to be relative to ${PREFIX}.
#
# SPECIAL_PERMS should be used primarily to change permissions of files or
# directories listed in the PLIST.  This may be used to make certain files
# set-uid or to change the ownership or a directory.
#
# SETUID_ROOT_PERMS is a convenience definition to note an executable is
# meant to be setuid-root, and should be used as follows:
#
#	SPECIAL_PERMS+=	/path/to/suidroot ${SETUID_ROOT_PERMS}
#
SPECIAL_PERMS?=		# empty
SETUID_ROOT_PERMS?=	${ROOT_USER} ${ROOT_GROUP} 4711

_INSTALL_PERMS_FILE=	${WRKDIR}/.install-perms
_INSTALL_UNPACK_TMPL+=	${_INSTALL_PERMS_FILE}
_INSTALL_PERMS_MEMBERS=	${SPECIAL_PERMS}

${_INSTALL_PERMS_FILE}: ../../mk/install/perms
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${.TARGET} ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${_FUNC_STRIP_PREFIX};						\
	exec 1>>${.TARGET}.tmp;						\
	${ECHO} "# start of install-perms";				\
	${ECHO} "#";							\
	${ECHO} "# Generate a +PERMS script that sets the special";	\
	${ECHO} "# permissions on files and directories used by the";	\
	${ECHO} "# package.";						\
	${ECHO} "#";							\
	${ECHO} "case \$${STAGE} in";					\
	${ECHO} "PRE-INSTALL|UNPACK)";					\
	${ECHO} "	\$${CAT} > ./+PERMS << 'EOF_PERMS'";		\
	${SED} ${FILES_SUBST_SED} ../../mk/install/perms;		\
	${ECHO} "";							\
	set -- dummy ${SPECIAL_PERMS}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		file="$$1"; owner="$$2"; group="$$3"; mode="$$4";	\
		shift; shift; shift; shift;				\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# PERMS: $$file $$mode $$owner $$group";	\
	done;								\
	${ECHO} "EOF_PERMS";						\
	${ECHO} "	\$${CHMOD} +x ./+PERMS";			\
	${ECHO} "	;;";						\
	${ECHO} "esac";							\
	${ECHO} "";							\
	${ECHO} "# end of install-perms";				\
	exec 1>/dev/null;						\
	${MV} -f ${.TARGET}.tmp ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	set -- dummy ${_INSTALL_PERMS_MEMBERS}; shift;			\
	if ${TEST} $$# -eq 0; then					\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi

# CONF_FILES are pairs of example and true config files, used much like
#	MLINKS in the base system.  At post-install time, if the true config
#	file doesn't exist, then the example one is copied into place.  At
#	deinstall time, the true one is removed if it doesn't differ from the
#	example one.  REQD_FILES is the same as CONF_FILES but the value
#	of PKG_CONFIG is ignored; however, all files listed in REQD_FILES
#	should be under ${PREFIX}.
#
# CONF_FILES_MODE and REQD_FILES_MODE are the file permissions for the
# files in CONF_FILES and REQD_FILES, respectively.
#
# CONF_FILES_PERMS are lists that look like:
#
#		example_file config_file user group mode
#
#	and works like CONF_FILES, except the config files are owned by
#	user:group have mode permissions.  REQD_FILES_PERMS is the same
#	as CONF_FILES_PERMS but the value of PKG_CONFIG is ignored;
#	however, all files listed in REQD_FILES_PERMS should be under
#	${PREFIX}.
#
# RCD_SCRIPTS works lists the basenames of the rc.d scripts.  They are
#	expected to be found in ${PREFIX}/share/examples/rc.d, and
#	the scripts will be copied into ${RCD_SCRIPTS_DIR} with
#	${RCD_SCRIPTS_MODE} permissions.
#
# If any file pathnames are relative, then they are taken to be relative
# to ${PREFIX}.
#
CONF_FILES?=		# empty
CONF_FILES_MODE?=	0644
CONF_FILES_PERMS?=	# empty
RCD_SCRIPTS?=		# empty
RCD_SCRIPTS_MODE?=	0755
RCD_SCRIPTS_EXAMPLEDIR=	share/examples/rc.d
RCD_SCRIPTS_SHELL?=	${SH}
FILES_SUBST+=		RCD_SCRIPTS_SHELL=${RCD_SCRIPTS_SHELL:Q}
MESSAGE_SUBST+=		RCD_SCRIPTS_DIR=${RCD_SCRIPTS_DIR}
MESSAGE_SUBST+=		RCD_SCRIPTS_EXAMPLEDIR=${RCD_SCRIPTS_EXAMPLEDIR}

_INSTALL_FILES_FILE=	${WRKDIR}/.install-files
_INSTALL_UNPACK_TMPL+=	${_INSTALL_FILES_FILE}
_INSTALL_FILES_MEMBERS=	${RCD_SCRIPTS} ${CONF_FILES} ${REQD_FILES}	\
			${CONF_FILES_PERMS} ${REQD_FILES_PERMS}

${_INSTALL_FILES_FILE}: ../../mk/install/files
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${.TARGET} ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}					\
	exec 1>>${.TARGET}.tmp;						\
	${ECHO} "# start of install-files";				\
	${ECHO} "#";							\
	${ECHO} "# Generate a +FILES script that reference counts config"; \
	${ECHO} "# files that are required for the proper functioning"; \
	${ECHO} "# of the package.";					\
	${ECHO} "#";							\
	${ECHO} "case \$${STAGE} in";					\
	${ECHO} "PRE-INSTALL|UNPACK)";					\
	${ECHO} "	\$${CAT} > ./+FILES << 'EOF_FILES'";		\
	${SED} ${FILES_SUBST_SED} ../../mk/install/files;		\
	${ECHO} ""
	${_PKG_SILENT}${_PKG_DEBUG}${_FUNC_STRIP_PREFIX};		\
	set -- dummy ${RCD_SCRIPTS}; shift;				\
	exec 1>>${.TARGET}.tmp;						\
	while ${TEST} $$# -gt 0; do					\
		script="$$1"; shift;					\
		file="${RCD_SCRIPTS_DIR:S/^${PREFIX}\///}/$$script";	\
		egfile="${RCD_SCRIPTS_EXAMPLEDIR}/$$script";		\
		${ECHO} "# FILE: $$file cr $$egfile ${RCD_SCRIPTS_MODE}"; \
	done
	${_PKG_SILENT}${_PKG_DEBUG}${_FUNC_STRIP_PREFIX};		\
	set -- dummy ${CONF_FILES}; shift;				\
	exec 1>>${.TARGET}.tmp;						\
	while ${TEST} $$# -gt 0; do					\
		egfile="$$1"; file="$$2";				\
		shift; shift;						\
		egfile=`strip_prefix "$$egfile"`;			\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# FILE: $$file c $$egfile ${CONF_FILES_MODE}"; \
	done
	${_PKG_SILENT}${_PKG_DEBUG}${_FUNC_STRIP_PREFIX};		\
	set -- dummy ${REQD_FILES}; shift;				\
	exec 1>>${.TARGET}.tmp;						\
	while ${TEST} $$# -gt 0; do					\
		egfile="$$1"; file="$$2";				\
		shift; shift;						\
		egfile=`strip_prefix "$$egfile"`;			\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# FILE: $$file cf $$egfile ${REQD_FILES_MODE}"; \
	done
	${_PKG_SILENT}${_PKG_DEBUG}${_FUNC_STRIP_PREFIX};		\
	set -- dummy ${CONF_FILES_PERMS}; shift;			\
	exec 1>>${.TARGET}.tmp;						\
	while ${TEST} $$# -gt 0; do					\
		egfile="$$1"; file="$$2";				\
		owner="$$3"; group="$$4"; mode="$$5";			\
		shift; shift; shift; shift; shift;			\
		egfile=`strip_prefix "$$egfile"`;			\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# FILE: $$file c $$egfile $$mode $$owner $$group"; \
	done
	${_PKG_SILENT}${_PKG_DEBUG}${_FUNC_STRIP_PREFIX};		\
	set -- dummy ${REQD_FILES_PERMS}; shift;			\
	exec 1>>${.TARGET}.tmp;						\
	while ${TEST} $$# -gt 0; do					\
		egfile="$$1"; file="$$2";				\
		owner="$$3"; group="$$4"; mode="$$5";			\
		shift; shift; shift; shift; shift;			\
		egfile=`strip_prefix "$$egfile"`;			\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# FILE: $$file cf $$egfile $$mode $$owner $$group"; \
	done
	${_PKG_SILENT}${_PKG_DEBUG}					\
	exec 1>>${.TARGET}.tmp;						\
	${ECHO} "EOF_FILES";						\
	${ECHO} "	\$${CHMOD} +x ./+FILES";			\
	${ECHO} "	;;";						\
	${ECHO} "esac";							\
	${ECHO} "";							\
	${ECHO} "# end of install-files";				\
	${MV} -f ${.TARGET}.tmp ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	set -- dummy ${_INSTALL_FILES_MEMBERS}; shift;			\
	if ${TEST} $$# -eq 0; then					\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi

# OWN_DIRS contains a list of directories for this package that should be
#       created and should attempt to be destroyed by the INSTALL/DEINSTALL
#	scripts.  MAKE_DIRS is used the same way, but the package admin
#	isn't prompted to remove the directory at post-deinstall time if it
#	isn't empty.  REQD_DIRS is like MAKE_DIRS but the value of PKG_CONFIG
#	is ignored; however, all directories listed in REQD_DIRS should
#	be under ${PREFIX}.
#
# OWN_DIRS_PERMS contains a list of "directory owner group mode" sublists
#	representing directories for this package that should be
#	created/destroyed by the INSTALL/DEINSTALL scripts.  MAKE_DIRS_PERMS
#	is used the same way but the package admin isn't prompted to remove
#	the directory at post-deinstall time if it isn't empty.
#	REQD_DIRS_PERMS is like MAKE_DIRS but the value of PKG_CONFIG is
#	ignored; however, all directories listed in REQD_DIRS should be
#	under ${PREFIX}.
#
# If any directory pathnames are relative, then they are taken to be
# relative to ${PREFIX}.
#
MAKE_DIRS?=		# empty
MAKE_DIRS_PERMS?=	# empty
REQD_DIRS?=		# empty
REQD_DIRS_PERMS?=	# empty
OWN_DIRS?=		# empty
OWN_DIRS_PERMS?=	# empty

_INSTALL_DIRS_FILE=	${WRKDIR}/.install-dirs
_INSTALL_UNPACK_TMPL+=	${_INSTALL_DIRS_FILE}
_INSTALL_DIRS_MEMBERS=	${PKG_SYSCONFSUBDIR} ${RCD_SCRIPTS}		\
			${CONF_FILES} ${CONF_FILES_PERMS}		\
			${MAKE_DIRS} ${MAKE_DIRS_PERMS}			\
			${REQD_DIRS} ${REDQ_DIRS_PERMS}			\
			${OWN_DIRS} ${OWN_DIRS_PERMS}

${_INSTALL_DIRS_FILE}: ../../mk/install/dirs
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${.TARGET} ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}					\
	exec 1>>${.TARGET}.tmp;						\
	${ECHO} "# start of install-dirs";				\
	${ECHO} "#";							\
	${ECHO} "# Generate a +DIRS script that reference counts directories"; \
	${ECHO} "# that are required for the proper functioning of the"; \
	${ECHO} "# package.";						\
	${ECHO} "#";							\
	${ECHO} "case \$${STAGE} in";					\
	${ECHO} "PRE-INSTALL|UNPACK)";					\
	${ECHO} "	\$${CAT} > ./+DIRS << 'EOF_DIRS'";		\
	${SED} ${FILES_SUBST_SED} ../../mk/install/dirs;		\
	${ECHO} ""
	${_PKG_SILENT}${_PKG_DEBUG}					\
	exec 1>>${.TARGET}.tmp;						\
	case ${PKG_SYSCONFSUBDIR:M*:Q}${CONF_FILES:M*:Q}${CONF_FILES_PERMS:M*:Q}"" in \
	"")	;;							\
	*)	${ECHO} "# DIR: ${PKG_SYSCONFDIR:S/${PREFIX}\///} m" ;;	\
	esac;								\
	case ${RCD_SCRIPTS:M*:Q}"" in					\
	"")	;;							\
	*)	${ECHO} "# DIR: ${RCD_SCRIPTS_DIR:S/${PREFIX}\///} m" ;; \
	esac
	${_PKG_SILENT}${_PKG_DEBUG}${_FUNC_STRIP_PREFIX};		\
	exec 1>>${.TARGET}.tmp;						\
	set -- dummy ${MAKE_DIRS}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir m";				\
	done;								\
	set -- dummy ${REQD_DIRS}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir fm";				\
	done;								\
	set -- dummy ${OWN_DIRS}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir mo";				\
	done
	${_PKG_SILENT}${_PKG_DEBUG}${_FUNC_STRIP_PREFIX};		\
	exec 1>>${.TARGET}.tmp;						\
	set -- dummy ${MAKE_DIRS_PERMS}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; owner="$$2"; group="$$3"; mode="$$4";	\
		shift; shift; shift; shift;				\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir m $$owner $$group $$mode";	\
	done;								\
	set -- dummy ${REQD_DIRS_PERMS}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; owner="$$2"; group="$$3"; mode="$$4";	\
		shift; shift; shift; shift;				\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir fm $$owner $$group $$mode";	\
	done;								\
	set -- dummy ${OWN_DIRS_PERMS}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; owner="$$2"; group="$$3"; mode="$$4";	\
		shift; shift; shift; shift;				\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir mo $$owner $$group $$mode";	\
	done
	${_PKG_SILENT}${_PKG_DEBUG}					\
	exec 1>>${.TARGET}.tmp;						\
	${ECHO} "EOF_DIRS";						\
	${ECHO} "	\$${CHMOD} +x ./+DIRS";				\
	${ECHO} "	;;";						\
	${ECHO} "esac";							\
	${ECHO} "";							\
	${ECHO} "# end of install-dirs";				\
	exec 1>/dev/null;						\
	${MV} -f ${.TARGET}.tmp ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	set -- dummy ${_INSTALL_DIRS_MEMBERS}; shift;			\
	if ${TEST} $$# -eq 0; then					\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi

# INFO_FILES contains names of info files that should be registered or
# 	removed from the info directory indices.  The listed info files
#	are assumed to be directly under ${INFO_DIR}.
#
INFO_FILES?=	# empty

_INSTALL_INFO_FILES_FILE=	${WRKDIR}/.install-info-files
_INSTALL_UNPACK_TMPL+=		${_INSTALL_INFO_FILES_FILE}
_INSTALL_INFO_FILES_MEMBERS=	${INFO_FILES}

.if !empty(INFO_FILES:M*)
USE_TOOLS+=	install-info:run
FILES_SUBST+=	INSTALL_INFO=${INSTALL_INFO:Q}
.endif

${_INSTALL_INFO_FILES_FILE}: ../../mk/install/info-files
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${.TARGET} ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${_FUNC_STRIP_PREFIX};						\
	exec 1>>${.TARGET}.tmp;						\
	${ECHO} "# start of install-info-files";			\
	${ECHO} "#";							\
	${ECHO} "# Generate an +INFO_FILES script that handles info file registration."; \
	${ECHO} "#";							\
	${ECHO} "case \$${STAGE} in";					\
	${ECHO} "PRE-INSTALL|UNPACK)";					\
	${ECHO} "	\$${CAT} > ./+INFO_FILES << 'EOF_INFO_FILES'";	\
	${SED} ${FILES_SUBST_SED} ../../mk/install/info-files;		\
	${ECHO} "";							\
	set -- dummy ${INFO_FILES}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		file="$$1"; shift;					\
		file=${INFO_DIR:Q}"/$$file";				\
		${ECHO} "# INFO: $$file";				\
	done;								\
	${ECHO} "EOF_INFO_FILES";					\
	${ECHO} "	\$${CHMOD} +x ./+INFO_FILES";			\
	${ECHO} "	;;";						\
	${ECHO} "esac";							\
	${ECHO} "";							\
	${ECHO} "# end of install-info-files";				\
	exec 1>/dev/null;						\
	${MV} -f ${.TARGET}.tmp ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	set -- dummy ${_INSTALL_INFO_FILES_MEMBERS}; shift;		\
	if ${TEST} $$# -eq 0; then					\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi

# PKG_SHELL contains the pathname of the shell that should be added or
#	removed from the shell database, /etc/shells.  If a pathname
#	is relative, then it is taken to be relative to ${PREFIX}.
#
PKG_SHELL?=		# empty

_INSTALL_SHELL_FILE=	${WRKDIR}/.install-shell
_INSTALL_UNPACK_TMPL+=	${_INSTALL_SHELL_FILE}
_INSTALL_SHELL_MEMBERS=	${PKG_SHELL}

${_INSTALL_SHELL_FILE}: ../../mk/install/shell
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${.TARGET} ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${_FUNC_STRIP_PREFIX};						\
	exec 1>>${.TARGET}.tmp;						\
	${ECHO} "# start of install-shell";				\
	${ECHO} "#";							\
	${ECHO} "# Generate a +SHELL script that handles shell registration."; \
	${ECHO} "#";							\
	${ECHO} "case \$${STAGE} in";					\
	${ECHO} "PRE-INSTALL|UNPACK)";					\
	${ECHO} "	\$${CAT} > ./+SHELL << 'EOF_SHELL'";		\
	${SED} ${FILES_SUBST_SED} ../../mk/install/shell;		\
	${ECHO} "";							\
	set -- dummy ${PKG_SHELL}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		shell="$$1"; shift;					\
		shell=`strip_prefix "$$shell"`;				\
		${ECHO} "# SHELL: $$shell";				\
	done;								\
	${ECHO} "EOF_SHELL";						\
	${ECHO} "	\$${CHMOD} +x ./+SHELL";			\
	${ECHO} "	;;";						\
	${ECHO} "esac";							\
	${ECHO} "";							\
	${ECHO} "# end of install-shell";				\
	exec 1>/dev/null;						\
	${MV} -f ${.TARGET}.tmp ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	set -- dummy ${_INSTALL_SHELLS_MEMBERS}; shift;			\
	if ${TEST} $$# -eq 0; then					\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi

# FONTS_DIRS.<type> are lists of directories in which the font databases
#	are updated.  If this is non-empty, then the appropriate tools is
#	used to update the fonts database for the font type.  The supported
#	types are:
#
#	    ttf		TrueType fonts
#	    type1	Type1 fonts
#	    x11		Generic X fonts, e.g. PCF, SNF, BDF, etc.
#
FONTS_DIRS.ttf?=	# empty
FONTS_DIRS.type1?=	# empty
FONTS_DIRS.x11?=	# empty

_INSTALL_FONTS_FILE=	${WRKDIR}/.install-fonts
_INSTALL_UNPACK_TMPL+=	${_INSTALL_FONTS_FILE}
_INSTALL_FONTS_MEMBERS=	${FONTS_DIRS.ttf} ${FONTS_DIRS.type1} ${FONTS_DIRS.x11}

# Directories with TTF and Type1 fonts also need to run mkfontdir, so
# list them as "x11" font directories as well.
#
.if !empty(FONTS_DIRS.ttf:M*)
USE_TOOLS+=		ttmkfdir:run
FILES_SUBST+=		TTMKFDIR=${TOOLS_PATH.ttmkfdir:Q}
FONTS_DIRS.x11+=	${FONTS_DIRS.ttf}
.endif
.if !empty(FONTS_DIRS.type1:M*)
USE_TOOLS+=		type1inst:run
FILES_SUBST+=		TYPE1INST=${TOOLS_PATH.type1inst:Q}
FONTS_DIRS.x11+=	${FONTS_DIRS.type1}
.endif
.if !empty(FONTS_DIRS.x11:M*)
USE_TOOLS+=		mkfontdir:run
FILES_SUBST+=		MKFONTDIR=${TOOLS_PATH.mkfontdir:Q}
.endif

${_INSTALL_FONTS_FILE}: ../../mk/install/fonts
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${.TARGET} ${.TARGET}.tmp
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${_FUNC_STRIP_PREFIX};						\
	exec 1>>${.TARGET}.tmp;						\
	${ECHO} "# start of install-fonts";				\
	${ECHO} "#";							\
	${ECHO} "# Generate a +FONTS script that updates fonts databases."; \
	${ECHO} "#";							\
	${ECHO} "case \$${STAGE} in";					\
	${ECHO} "PRE-INSTALL|UNPACK)";					\
	${ECHO} "	\$${CAT} > ./+FONTS << 'EOF_FONTS'";		\
	${SED} ${FILES_SUBST_SED} ../../mk/install/fonts;		\
	${ECHO} "";							\
	set -- dummy ${FONTS_DIRS.ttf}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# FONTS: $$dir ttf";				\
	done;								\
	set -- dummy ${FONTS_DIRS.type1}; shift;			\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# FONTS: $$dir type1";				\
	done;								\
	set -- dummy ${FONTS_DIRS.x11}; shift;				\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# FONTS: $$dir x11";				\
	done;								\
	${ECHO} "EOF_FONTS";						\
	${ECHO} "	\$${CHMOD} +x ./+FONTS";			\
	${ECHO} "	;;";						\
	${ECHO} "esac";							\
	${ECHO} "";							\
	${ECHO} "# end of install-fonts";				\
	exec 1>/dev/null;						\
	${MV} -f ${.TARGET}.tmp ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	set -- dummy ${_INSTALL_FONTS_MEMBERS}; shift;			\
	if ${TEST} $$# -eq 0; then					\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi

# PKG_CREATE_USERGROUP indicates whether the INSTALL script should
#	automatically add any needed users/groups to the system using
#	useradd/groupadd.  It is either YES or NO and defaults to YES.
#
# PKG_CONFIG indicates whether the INSTALL/DEINSTALL scripts should do
#	automatic config file and directory handling, or if it should
#	merely inform the admin of the list of required files and
#	directories needed to use the package.  It is either YES or NO
#	and defaults to YES.
#
# PKG_RCD_SCRIPTS indicates whether to automatically install rc.d scripts
#	to ${RCD_SCRIPTS_DIR}.  It is either YES or NO and defaults to
#	NO.  This variable only takes effect if ${PKG_CONFIG} == "YES".
#
# PKG_REGISTER_SHELLS indicates whether to automatically register shells
#	in /etc/shells.  It is either YES or NO and defaults to YES.
#
# PKG_UPDATE_FONTS_DB indicates whether to automatically update the fonts
#	databases in directories where fonts have been installed or
#	removed.  It is either YES or NO and defaults to YES.
#
# These values merely set the defaults for INSTALL/DEINSTALL scripts, but
# they may be overridden by resetting them in the environment.
#
PKG_CREATE_USERGROUP?=	YES
PKG_CONFIG?=		YES
PKG_RCD_SCRIPTS?=	NO
PKG_REGISTER_SHELLS?=	YES
PKG_UPDATE_FONTS_DB?=	YES
FILES_SUBST+=		PKG_CREATE_USERGROUP=${PKG_CREATE_USERGROUP:Q}
FILES_SUBST+=		PKG_CONFIG=${PKG_CONFIG:Q}
FILES_SUBST+=		PKG_RCD_SCRIPTS=${PKG_RCD_SCRIPTS:Q}
FILES_SUBST+=		PKG_REGISTER_SHELLS=${PKG_REGISTER_SHELLS:Q}
FILES_SUBST+=		PKG_UPDATE_FONTS_DB=${PKG_UPDATE_FONTS_DB:Q}

# Substitute for various programs used in the DEINSTALL/INSTALL scripts and
# in the rc.d scripts.
#
FILES_SUBST+=		AWK=${AWK:Q}
FILES_SUBST+=		BASENAME=${BASENAME:Q}
FILES_SUBST+=		CAT=${CAT:Q}
FILES_SUBST+=		CHGRP=${CHGRP:Q}
FILES_SUBST+=		CHMOD=${CHMOD:Q}
FILES_SUBST+=		CHOWN=${CHOWN:Q}
FILES_SUBST+=		CMP=${CMP:Q}
FILES_SUBST+=		CP=${CP:Q}
FILES_SUBST+=		DIRNAME=${DIRNAME:Q}
FILES_SUBST+=		ECHO=${ECHO:Q}
FILES_SUBST+=		ECHO_N=${ECHO_N:Q}
FILES_SUBST+=		EGREP=${EGREP:Q}
FILES_SUBST+=		EXPR=${EXPR:Q}
FILES_SUBST+=		FALSE=${FALSE:Q}
FILES_SUBST+=		FIND=${FIND:Q}
FILES_SUBST+=		GREP=${GREP:Q}
FILES_SUBST+=		GROUPADD=${GROUPADD:Q}
FILES_SUBST+=		GTAR=${GTAR:Q}
FILES_SUBST+=		HEAD=${HEAD:Q}
FILES_SUBST+=		ID=${ID:Q}
FILES_SUBST+=		INSTALL_INFO=${INSTALL_INFO:Q}
FILES_SUBST+=		LINKFARM=${LINKFARM:Q}
FILES_SUBST+=		LN=${LN:Q}
FILES_SUBST+=		LS=${LS:Q}
FILES_SUBST+=		MKDIR=${MKDIR:Q}
FILES_SUBST+=		MV=${MV:Q}
FILES_SUBST+=		PERL5=${PERL5:Q}
FILES_SUBST+=		PKG_ADMIN=${PKG_ADMIN_CMD:Q}
FILES_SUBST+=		PKG_INFO=${PKG_INFO_CMD:Q}
FILES_SUBST+=		PW=${PW:Q}
FILES_SUBST+=		PWD_CMD=${PWD_CMD:Q}
FILES_SUBST+=		RM=${RM:Q}
FILES_SUBST+=		RMDIR=${RMDIR:Q}
FILES_SUBST+=		SED=${SED:Q}
FILES_SUBST+=		SETENV=${SETENV:Q}
FILES_SUBST+=		SH=${SH:Q}
FILES_SUBST+=		SORT=${SORT:Q}
FILES_SUBST+=		SU=${SU:Q}
FILES_SUBST+=		TEST=${TEST:Q}
FILES_SUBST+=		TOUCH=${TOUCH:Q}
FILES_SUBST+=		TR=${TR:Q}
FILES_SUBST+=		TRUE=${TRUE:Q}
FILES_SUBST+=		USERADD=${USERADD:Q}
FILES_SUBST+=		XARGS=${XARGS:Q}

FILES_SUBST_SED=	${FILES_SUBST:S/=/@!/:S/$/!g/:S/^/ -e s!@/}

PKG_REFCOUNT_DBDIR?=	${PKG_DBDIR}.refcount

INSTALL_SCRIPTS_ENV=	PKG_PREFIX=${PREFIX}
INSTALL_SCRIPTS_ENV+=	PKG_METADATA_DIR=${_PKG_DBDIR}/${PKGNAME}
INSTALL_SCRIPTS_ENV+=	PKG_REFCOUNT_DBDIR=${PKG_REFCOUNT_DBDIR}

.PHONY: pre-install-script post-install-script

# This section is the only part that hooks into the INSTALL/DEINSTALL
# script logic in bsd.pkg.mk
#
.if !empty(_USE_PKGINSTALL:M[yY][eE][sS])
.  if !empty(DEINSTALL_SRC)
DEINSTALL_FILE=		${PKG_DB_TMPDIR}/+DEINSTALL
.  endif
.  if !empty(INSTALL_SRC)
INSTALL_FILE=		${PKG_DB_TMPDIR}/+INSTALL
.  endif

pre-install-script: generate-install-scripts
	${_PKG_SILENT}${_PKG_DEBUG}cd ${PKG_DB_TMPDIR} &&		\
		${SETENV} ${INSTALL_SCRIPTS_ENV}			\
		${_PKG_DEBUG_SCRIPT} ${INSTALL_FILE} ${PKGNAME} PRE-INSTALL

post-install-script:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${PKG_DB_TMPDIR} &&		\
		${SETENV} ${INSTALL_SCRIPTS_ENV}			\
		${_PKG_DEBUG_SCRIPT} ${INSTALL_FILE} ${PKGNAME} POST-INSTALL
.endif

.PHONY: generate-install-scripts
post-build: generate-install-scripts
generate-install-scripts:	# do nothing

.if !empty(DEINSTALL_SRC)
generate-install-scripts: ${DEINSTALL_FILE}
${DEINSTALL_FILE}: ${DEINSTALL_SRC}
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${CAT} ${.ALLSRC} |			\
		${SED} ${FILES_SUBST_SED} > ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}${CHMOD} +x ${.TARGET}
.endif

.if !empty(INSTALL_SRC)
generate-install-scripts: ${INSTALL_FILE}
${INSTALL_FILE}: ${INSTALL_SRC}
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}${CAT} ${.ALLSRC} |			\
		${SED} ${FILES_SUBST_SED} > ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}${CHMOD} +x ${.TARGET}
.endif

# rc.d scripts are automatically generated and installed into the rc.d
# scripts example directory at the post-install step.  The following
# variables are relevent to this process:
#
# RCD_SCRIPTS			lists the basenames of the rc.d scripts
#
# RCD_SCRIPT_SRC.<script>	the source file for <script>; this will
#				be run through FILES_SUBST to generate
#				the rc.d script (defaults to
#				${FILESDIR}/<script>.sh)
#
# If the source rc.d script is not present, then the automatic handling
# doesn't occur.

.PHONY: generate-rcd-scripts
post-build: generate-rcd-scripts
generate-rcd-scripts:	# do nothing

.PHONY: install-rcd-scripts
post-install: install-rcd-scripts
install-rcd-scripts:	# do nothing

.for _script_ in ${RCD_SCRIPTS}
RCD_SCRIPT_SRC.${_script_}?=	${FILESDIR}/${_script_}.sh
RCD_SCRIPT_WRK.${_script_}?=	${WRKDIR}/${_script_}

.  if !empty(RCD_SCRIPT_SRC.${_script_})
.    if exists(${RCD_SCRIPT_SRC.${_script_}})
generate-rcd-scripts: ${RCD_SCRIPT_WRK.${_script_}}
${RCD_SCRIPT_WRK.${_script_}}: ${RCD_SCRIPT_SRC.${_script_}}
	@${ECHO_MSG} "${_PKGSRC_IN}> Creating ${.TARGET}"
	${_PKG_SILENT}${_PKG_DEBUG}${CAT} ${.ALLSRC} |			\
		${SED} ${FILES_SUBST_SED} > ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}${CHMOD} +x ${.TARGET}

install-rcd-scripts: install-rcd-${_script_}
install-rcd-${_script_}: ${RCD_SCRIPT_WRK.${_script_}}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -f ${RCD_SCRIPT_WRK.${_script_}} ]; then			\
		${MKDIR} ${PREFIX}/${RCD_SCRIPTS_EXAMPLEDIR};		\
		${INSTALL_SCRIPT} ${RCD_SCRIPT_WRK.${_script_}}		\
			${PREFIX}/${RCD_SCRIPTS_EXAMPLEDIR}/${_script_}; \
	fi
.    endif
.  endif
.endfor
