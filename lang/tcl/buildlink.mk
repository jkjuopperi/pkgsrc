# $NetBSD: buildlink.mk,v 1.1 2001/06/21 18:54:37 jlam Exp $
#
# This Makefile fragment is included by packages that use tcl.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define TCL_REQD to the version of tcl desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(TCL_BUILDLINK_MK)
TCL_BUILDLINK_MK=	# defined

TCL_REQD?=		8.3.2
DEPENDS+=		tcl>=${TCL_REQD}:../../lang/tcl

BUILDLINK_PREFIX.tcl=	${LOCALBASE}
BUILDLINK_FILES.tcl=	include/tcl.h
BUILDLINK_FILES.tcl+=	include/tclDecls.h
BUILDLINK_FILES.tcl+=	include/tcl/*/*.h
BUILDLINK_FILES.tcl+=	lib/libtcl83.*
BUILDLINK_FILES.tcl+=	lib/libtclstub83.*

BUILDLINK_TARGETS.tcl=	tcl-buildlink
BUILDLINK_TARGETS.tcl+=	tclConfig-buildlink
BUILDLINK_TARGETS+=	${BUILDLINK_TARGETS.tcl}

pre-configure: ${BUILDLINK_TARGETS.tcl}
tcl-buildlink: _BUILDLINK_USE

tclConfig-buildlink:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cookie=${BUILDLINK_DIR}/.tclConfig_buildlink_done;		\
	if [ ! -f $${cookie} ]; then					\
		file=lib/tclConfig.sh;					\
		${ECHO_MSG} "Creating script ${BUILDLINK_DIR}/$${file}."; \
		${SED}	-e "s|-L${LOCALBASE}/lib|-L${BUILDLINK_DIR}/lib|g" \
			-e "s|${LOCALBASE}/lib/libtclstub|${BUILDLINK_DIR}/lib/libtclstub|g" \
			${LOCALBASE}/$${file} > ${BUILDLINK_DIR}/$${file}; \
		${CHMOD} +x ${BUILDLINK_DIR}/$${file};			\
		${TOUCH} ${TOUCH_FLAGS} $${cookie};			\
	fi

.include "../../mk/bsd.buildlink.mk"

.endif	# TCL_BUILDLINK_MK
