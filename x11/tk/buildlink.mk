# $NetBSD: buildlink.mk,v 1.1 2001/06/21 21:41:35 jlam Exp $
#
# This Makefile fragment is included by packages that use tk.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define TK_REQD to the version of tk desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(TK_BUILDLINK_MK)
TK_BUILDLINK_MK=	# defined

TK_REQD?=		8.3.2
DEPENDS+=		tk>=${TK_REQD}:../../x11/tk

BUILDLINK_PREFIX.tk=	${LOCALBASE}
BUILDLINK_FILES.tk=	include/tk.h
BUILDLINK_FILES.tk+=	include/tkInt.h
BUILDLINK_FILES.tk+=	include/tkDecls.h
BUILDLINK_FILES.tk+=	include/tkIntXlibDecls.h
BUILDLINK_FILES.tk+=	include/tk/*/*.h
BUILDLINK_FILES.tk+=	lib/libtk83.*
BUILDLINK_FILES.tk+=	lib/libtkstub83.*

.include "../../lang/tcl/buildlink.mk"

BUILDLINK_TARGETS.tk=	tk-buildlink
BUILDLINK_TARGETS.tk+=	tkConfig-buildlink
BUILDLINK_TARGETS+=	${BUILDLINK_TARGETS.tk}

pre-configure: ${BUILDLINK_TARGETS.tk}
tk-buildlink: _BUILDLINK_USE

tkConfig-buildlink:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cookie=${BUILDLINK_DIR}/.tkConfig_buildlink_done;		\
	if [ ! -f $${cookie} ]; then					\
		file=lib/tkConfig.sh;					\
		${ECHO_MSG} "Creating script ${BUILDLINK_DIR}/$${file}."; \
		${SED}	-e "s|-L${LOCALBASE}/lib|-L${BUILDLINK_DIR}/lib|g" \
			-e "s|${LOCALBASE}/lib/libtkstub|-L${BUILDLINK_DIR}/lib/libtkstub|g" \
			${LOCALBASE}/$${file} > ${BUILDLINK_DIR}/$${file}; \
		${CHMOD} +x ${BUILDLINK_DIR}/$${file};			\
		${TOUCH} ${TOUCH_FLAGS} $${cookie};			\
	fi

.include "../../mk/bsd.buildlink.mk"

.endif	# TK_BUILDLINK_MK
