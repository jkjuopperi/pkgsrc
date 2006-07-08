# $NetBSD: buildlink3.mk,v 1.8 2006/07/08 22:39:30 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
RPM_BUILDLINK3_MK:=	${RPM_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	rpm
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nrpm}
BUILDLINK_PACKAGES+=	rpm
BUILDLINK_ORDER+=	rpm

.if !empty(RPM_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.rpm+=	rpm>=2.5.4nb4
BUILDLINK_ABI_DEPENDS.rpm?=	rpm>=2.5.4nb5
BUILDLINK_PKGSRCDIR.rpm?=	../../misc/rpm
BUILDLINK_DEPMETHOD.rpm?=	build

BUILDLINK_CPPFLAGS.rpm= -I${BUILDLINK_PREFIX.rpm}/include/rpm
.endif	# RPM_BUILDLINK3_MK

.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/zlib/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
