# $NetBSD: buildlink2.mk,v 1.1 2002/09/20 00:43:33 jlam Exp $

.if !defined(P5_DBI_BUILDLINK2_MK)
P5_DBI_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		p5-DBI
BUILDLINK_DEPENDS.p5-DBI?=	p5-DBI>=1.30
BUILDLINK_PKGSRCDIR.p5-DBI?=	../../databases/p5-DBI

.include "../../lang/perl5/buildlink2.mk"

BUILDLINK_PREFIX.p5-DBI=	${BUILDLINK_PREFIX.perl}
BUILDLINK_FILES.p5-DBI= \
	${PERL5_SITEARCH:S/^${BUILDLINK_PREFIX.perl}\///}/auto/DBI/*

BUILDLINK_TARGETS+=	p5-DBI-buildlink

p5-DBI-buildlink: _BUILDLINK_USE

.endif	# P5_DBI_BUILDLINK2_MK
