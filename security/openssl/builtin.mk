# $NetBSD: builtin.mk,v 1.6 2004/12/03 23:03:09 jlam Exp $

_OPENSSL_PKGSRC_PKGNAME=	openssl-0.9.6m
_OPENSSL_OPENSSLV_H=		/usr/include/openssl/opensslv.h

.for _lib_ in des
.  if !defined(_BLNK_LIB_FOUND.${_lib_})
_BLNK_LIB_FOUND.${_lib_}!=	\
	if ${TEST} "`${ECHO} /usr/lib/lib${_lib_}.*`" != "/usr/lib/lib${_lib_}.*"; then \
		${ECHO} "yes";						\
	elif ${TEST} "`${ECHO} /lib/lib${_lib_}.*`" != "/lib/lib${_lib_}.*"; then \
		${ECHO} "yes";						\
	else								\
		${ECHO} "no";						\
	fi
BUILDLINK_VARS+=	_BLNK_LIB_FOUND.${_lib_}
.  endif
.endfor
.undef _lib_

.if !defined(IS_BUILTIN.openssl)
IS_BUILTIN.openssl=	no
.  if exists(${_OPENSSL_OPENSSLV_H})
IS_BUILTIN.openssl=	yes
#
# Create an appropriate name for the built-in package distributed
# with the system.  This package name can be used to check against
# BUILDLINK_DEPENDS.<pkg> to see if we need to install the pkgsrc
# version or if the built-in one is sufficient.
#
_OPENSSL_MAJOR!=							\
	${AWK} 'BEGIN { hex="0123456789abcdef" }			\
		/\#define[ 	]*OPENSSL_VERSION_NUMBER/ {		\
			i = index(hex, substr($$3, 3, 1)) - 1;		\
			print i;					\
			exit 0;						\
		}							\
	' ${_OPENSSL_OPENSSLV_H}
_OPENSSL_MINOR!=							\
	${AWK} 'BEGIN { hex="0123456789abcdef" }			\
		/\#define[ 	]*OPENSSL_VERSION_NUMBER/ {		\
			i = 16 * (index(hex, substr($$3, 4, 1)) - 1);	\
			i += index(hex, substr($$3, 5, 1)) - 1;		\
			print i;					\
			exit 0;						\
		}							\
	' ${_OPENSSL_OPENSSLV_H}
_OPENSSL_TEENY!=							\
	${AWK} 'BEGIN { hex="0123456789abcdef" }			\
		/\#define[ 	]*OPENSSL_VERSION_NUMBER/ {		\
			i = 16 * (index(hex, substr($$3, 6, 1)) - 1);	\
			i += index(hex, substr($$3, 7, 1)) - 1;		\
			print i;					\
			exit 0;						\
		}							\
	' ${_OPENSSL_OPENSSLV_H}
_OPENSSL_PATCHLEVEL!=							\
	${AWK} 'BEGIN { hex="0123456789abcdef";				\
			split("abcdefghijklmnopqrstuvwxyz", alpha, "");	\
		}							\
		/\#define[ 	]*OPENSSL_VERSION_NUMBER/ {		\
			i = 16 * (index(hex, substr($$3, 8, 1)) - 1);	\
			i += index(hex, substr($$3, 9, 1)) - 1;		\
			if (i == 0) {					\
				print "";				\
			} else if (i > 26) {				\
				print "a";				\
			} else {					\
				print alpha[i];				\
			}						\
			exit 0;						\
		}							\
	' ${_OPENSSL_OPENSSLV_H}
_OPENSSL_VERSION=	${_OPENSSL_MAJOR}.${_OPENSSL_MINOR}.${_OPENSSL_TEENY}${_OPENSSL_PATCHLEVEL}
BUILTIN_PKG.openssl=	openssl-${_OPENSSL_VERSION}
.    if !empty(_OPENSSL_VERSION:M0\.9\.6g)
#
# If the native OpenSSL contains the security fixes pulled up to the
# netbsd-1-6 branch on 2003-11-07, then pretend it's openssl-0.9.6l.
#    
_OPENSSL_HAS_20031107_FIX!=						\
	${AWK} 'BEGIN { ans = "no" }					\
		/OPENSSL_HAS_20031107_FIX/ { ans = "yes" }		\
		END { print ans; exit 0 }				\
	' ${_OPENSSL_OPENSSLV_H}
.      if !empty(_OPENSSL_HAS_20031107_FIX:M[yY][eE][sS])
BUILTIN_PKG.openssl=	openssl-0.9.6l
.      endif
#
# If the native OpenSSL contains the security fixes pulled up to the
# netbsd-1-6 branch on 2004-04-01, then pretend it's openssl-0.9.6m.
#    
_OPENSSL_HAS_20040401_FIX!=						\
	${AWK} 'BEGIN { ans = "no" }					\
		/OPENSSL_HAS_20040401_FIX/ { ans = "yes" }		\
		END { print ans; exit 0 }				\
	' ${_OPENSSL_OPENSSLV_H}
.      if !empty(_OPENSSL_HAS_20040401_FIX:M[yY][eE][sS])
BUILTIN_PKG.openssl=	openssl-0.9.6m
.      endif
.    endif
BUILDLINK_VARS+=	BUILTIN_PKG.openssl
.  endif
BUILDLINK_VARS+=	IS_BUILTIN.openssl
.endif	# IS_BUILTIN.openssl

.if !defined(USE_BUILTIN.openssl)
USE_BUILTIN.openssl?=	${IS_BUILTIN.openssl}

.  if defined(BUILTIN_PKG.openssl)
USE_BUILTIN.openssl=	yes
.    for _depend_ in ${BUILDLINK_DEPENDS.openssl}
.      if !empty(USE_BUILTIN.openssl:M[yY][eE][sS])
USE_BUILTIN.openssl!=	\
	if ${PKG_ADMIN} pmatch '${_depend_}' ${BUILTIN_PKG.openssl}; then \
		${ECHO} "yes";						\
	else								\
		${ECHO} "no";						\
	fi
.      endif
.    endfor
.  endif
.endif	# USE_BUILTIN.openssl

CHECK_BUILTIN.openssl?=	no
.if !empty(CHECK_BUILTIN.openssl:M[nN][oO])

.if !defined(_NEED_NEWER_OPENSSL)
_NEED_NEWER_OPENSSL?=	no
.  for _depend_ in ${BUILDLINK_DEPENDS.openssl}
.    if !empty(_NEED_NEWER_OPENSSL:M[nN][oO])
_NEED_NEWER_OPENSSL!=	\
	if ${PKG_ADMIN} pmatch '${_depend_}' ${_OPENSSL_PKGSRC_PKGNAME}; then \
		${ECHO} "no";						\
	else								\
		${ECHO} "yes";						\
	fi
.    endif
.  endfor
BUILDLINK_VARS+=	_NEED_NEWER_OPENSSL
.endif

.if !empty(USE_BUILTIN.openssl:M[nN][oO]) && \
    !empty(_NEED_NEWER_OPENSSL:M[yY][eE][sS])
PKG_SKIP_REASON=	\
	"Unable to satisfy dependency: ${BUILDLINK_DEPENDS.openssl}"
.endif

# By default, we don't bother with the old DES API.
USE_OLD_DES_API?=	no

.if !empty(USE_BUILTIN.openssl:M[yY][eE][sS])
BUILDLINK_PREFIX.openssl=	/usr
#
# If we're using the old DES API, then check to see if the old DES
# code was factored out into a separate library and header files and
# no longer a part of libcrypto.
#
.  if !empty(USE_OLD_DES_API:M[yY][eE][sS]) && \
      !exists(${BUILDLINK_PREFIX.openssl}/include/openssl/des_old.h)
.    if exists(${BUILDLINK_PREFIX.openssl}/include/des.h) && \
        !empty(_BLNK_LIB_FOUND.des:M[yY][eE][sS])
BUILDLINK_TRANSFORM+=		l:crypto:des:crypto
WRAPPER_REORDER_CMDS+=		reorder:l:des:crypto
.    endif

BUILDLINK_TARGETS+=		buildlink-openssl-des-old.h
.    if !target(buildlink-openssl-des-old.h)
.PHONY: buildlink-openssl-des-old.h
buildlink-openssl-des-old.h:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	dest="${BUILDLINK_DIR}/include/openssl/des_old.h";		\
	if ${TEST} ! -f "$$dest"; then					\
		for src in						\
			${BUILDLINK_PREFIX.openssl}/include/des.h	\
			${BUILDLINK_PREFIX.openssl}/include/openssl/des.h; \
		do							\
			if ${TEST} -f "$$src"; then			\
				${MKDIR} -p `${DIRNAME} "$$dest"`;	\
				${LN} -fs $$src $$dest;			\
				break;					\
			fi;						\
		done;							\
	fi
.    endif
.  endif # USE_OLD_DES_API == yes
.endif	# USE_BUILTIN.openssl == yes

.if defined(PKG_SYSCONFDIR.openssl)
SSLCERTS=	${PKG_SYSCONFDIR.openssl}/certs
.elif ${OPSYS} == "NetBSD"
SSLCERTS=	/etc/openssl/certs
.elif !empty(USE_BUILTIN.openssl:M[yY][eE][sS])
SSLCERTS=	/etc/ssl/certs		# likely place where certs live
.else
SSLCERTS=	${PKG_SYSCONFBASEDIR}/openssl/certs
.endif
BUILD_DEFS+=	SSLCERTS

.endif	# CHECK_BUILTIN.openssl
