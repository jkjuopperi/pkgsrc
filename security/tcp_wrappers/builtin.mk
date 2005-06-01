# $NetBSD: builtin.mk,v 1.6 2005/06/01 18:03:21 jlam Exp $

BUILTIN_PKG:=	tcp_wrappers

BUILTIN_FIND_LIBS:=			wrap
BUILTIN_FIND_FILES_VAR:=		H_TCP_WRAPPERS
BUILTIN_FIND_FILES.H_TCP_WRAPPERS=	/usr/include/tcpd.h

.include "../../mk/buildlink3/bsd.builtin.mk"

###
### Determine if there is a built-in implementation of the package and
### set IS_BUILTIN.<pkg> appropriately ("yes" or "no").
###
.if !defined(IS_BUILTIN.tcp_wrappers)
IS_BUILTIN.tcp_wrappers=	no
.  if empty(H_TCP_WRAPPERS:M${LOCALBASE}/*) && \
      exists(${H_TCP_WRAPPERS}) && \
      !empty(BUILTIN_LIB_FOUND.wrap:M[yY][eE][sS])
IS_BUILTIN.tcp_wrappers=	yes
.  endif
.endif
MAKEVARS+=	IS_BUILTIN.tcp_wrappers

###
### Determine whether we should use the built-in implementation if it
### exists, and set USE_BUILTIN.<pkg> appropriate ("yes" or "no").
###
.if !defined(USE_BUILTIN.tcp_wrappers)
.  if ${PREFER.tcp_wrappers} == "pkgsrc"
USE_BUILTIN.tcp_wrappers=	no
.  else
USE_BUILTIN.tcp_wrappers=	${IS_BUILTIN.tcp_wrappers}
.    if defined(BUILTIN_PKG.tcp_wrappers) && \
        !empty(IS_BUILTIN.tcp_wrappers:M[yY][eE][sS])
USE_BUILTIN.tcp_wrappers=	yes
.      for _dep_ in ${BUILDLINK_DEPENDS.tcp_wrappers}
.        if !empty(USE_BUILTIN.tcp_wrappers:M[yY][eE][sS])
USE_BUILTIN.tcp_wrappers!=						\
	if ${PKG_ADMIN} pmatch ${_dep_:Q} ${BUILTIN_PKG.tcp_wrappers:Q}; then \
		${ECHO} yes;						\
	else								\
		${ECHO} no;						\
	fi
.        endif
.      endfor
.    endif
.  endif  # PREFER.tcp_wrappers
.endif
MAKEVARS+=	USE_BUILTIN.tcp_wrappers
