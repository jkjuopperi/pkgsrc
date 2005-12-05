# $NetBSD: buildlink3.mk,v 1.10 2005/12/05 20:51:03 rillig Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
INTLTOOL_BUILDLINK3_MK:=	${INTLTOOL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	intltool
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nintltool}
BUILDLINK_PACKAGES+=	intltool

.if !empty(INTLTOOL_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.intltool+=	intltool>=0.34.1
BUILDLINK_PKGSRCDIR.intltool?=	../../textproc/intltool
BUILDLINK_DEPMETHOD.intltool?=	build
.endif	# INTLTOOL_BUILDLINK3_MK

USE_TOOLS+=		perl

.if !empty(INTLTOOL_BUILDLINK3_MK:M+)
CONFIGURE_ENV+=		INTLTOOL_PERL=${PERL5:Q}
INTLTOOLIZE=		${BUILDLINK_PREFIX.intltool}/bin/intltoolize
INTLTOOL_OVERRIDE?=	intltool-* */intltool-*

_CONFIGURE_POSTREQ+=	override-intltool

.PHONY: override-intltool
override-intltool:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${ECHO} "=> Overriding intltool."
	@cd ${WRKSRC} && for f in ${INTLTOOL_OVERRIDE}; do		\
	    if ${TEST} -f ${BUILDLINK_PREFIX.intltool}/bin/${f}; then	\
	        ${CP} ${BUILDLINK_PREFIX.intltool}/bin/${f} ${f};	\
	    fi;								\
	done
.endif	# INTLTOOL_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
