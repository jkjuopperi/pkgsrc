# $NetBSD: buildlink2.mk,v 1.1 2003/01/05 05:01:21 rh Exp $
#
# This Makefile fragment is included by packages that use xml-i18n-tools.
#

.if !defined(XML_I18N_TOOLS_BUILDLINK2_MK)
XML_I18N_TOOLS_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			xml-i18n-tools
BUILDLINK_DEPENDS.xml-i18n-tools?=	xml-i18n-tools>=0.9
BUILDLINK_PKGSRCDIR.xml-i18n-tools?=	../../textproc/xml-i18n-tools

EVAL_PREFIX+=	BUILDLINK_PREFIX.xml-i18n-tools=xml-i18n-tools
BUILDLINK_PREFIX.xml-i18n-tools_DEFAULT=	${LOCALBASE}

BUILDLINK_TARGETS+=	xml-i18n-tools-buildlink

xml-i18n-tools-buildlink: _BUILDLINK_USE

.endif	# XML_I18N_TOOLS_BUILDLINK2_MK
