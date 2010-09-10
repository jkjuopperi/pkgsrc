# $NetBSD: buildlink3.mk,v 1.12 2010/09/10 08:35:16 taca Exp $

BUILDLINK_TREE+=	${RUBY_PKGPREFIX}-rdtool

.if !defined(RUBY_RDTOOL_BUILDLINK3_MK)
RUBY_RDTOOL_BUILDLINK3_MK:=

RUBY_RD=		rd2
RUBY_RD_VERSION =	0.6.18
RUBY_RD_REQD=		0.6.14

# create string for dependency list
#_RUBY_RD_LIST:=	${RUBY_VERSION_LIST:C/([1-9][0-9]*)/ruby&-rdtool/g:ts,}

BUILDLINK_FILES.${RUBY_PKGPREFIX}-rdtool+=	bin/rd2
BUILDLINK_DEPMETHOD.${RUBY_PKGPREFIX}-rdtool?=	build
BUILDLINK_API_DEPENDS.${RUBY_PKGPREFIX}-rdtool+=${RUBY_PKGPREFIX}-rdtool>=0.6.14
BUILDLINK_PKGSRCDIR.${RUBY_PKGPREFIX}-rdtool?=	../../textproc/ruby-rdtool

.endif # RUBY_RDTOOL_BUILDLINK3_MK

BUILDLINK_TREE+=	-${RUBY_PKGPREFIX}-rdtool
