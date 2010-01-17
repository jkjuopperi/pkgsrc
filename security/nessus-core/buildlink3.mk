# $NetBSD: buildlink3.mk,v 1.17 2010/01/17 12:02:41 wiz Exp $

BUILDLINK_TREE+=	nessus-core

.if !defined(NESSUS_CORE_BUILDLINK3_MK)
NESSUS_CORE_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.nessus-core+=	nessus-core>=2.2.11
BUILDLINK_ABI_DEPENDS.nessus-core?=	nessus-core>=2.2.11nb3
BUILDLINK_PKGSRCDIR.nessus-core?=	../../security/nessus-core

.include "../../security/libnasl/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"
.endif # NESSUS_CORE_BUILDLINK3_MK

BUILDLINK_TREE+=	-nessus-core
