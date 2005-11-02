# $NetBSD: buildlink3.mk,v 1.6 2005/11/02 07:44:02 taca Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
RUBY_BUILDLINK3_MK:=	${RUBY_BUILDLINK3_MK}+

.if !defined(_RUBYVERSION_MK)
.include "../../lang/ruby/rubyversion.mk"
.endif

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	${RUBY_BASE}
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:N${RUBY_BASE}}
BUILDLINK_PACKAGES+=	${RUBY_BASE}

.if !empty(RUBY_BUILDLINK3_MK:M+)

BUILDLINK_DEPENDS.${RUBY_BASE}?=	${RUBY_BASE}>=${RUBY_REQD}
BUILDLINK_RECOMMENDED.${RUBY_BASE}?=	${RUBY_BASE}>=${RUBY_VERSION}
BUILDLINK_PKGSRCDIR.${RUBY_BASE}?=	../../lang/${RUBY_BASE}
BUILDLINK_FILES.${RUBY_BASE}+=		lib/libruby${RUBY_VER}.*
BUILDLINK_FILES.${RUBY_BASE}+=	lib/ruby/${RUBY_VER_DIR}/${RUBY_ARCH}/*.h

BUILDLINK_TARGETS+=	buildlink-bin-ruby

buildlink-bin-ruby:
	${_PKG_SILENT}${_PKG_DEBUG} \
	f=${BUILDLINK_PREFIX.${RUBY_BASE}:Q}"/bin/ruby${RUBY_VER}"; \
	if ${TEST} -f $$f; then \
		${LN} -s $$f ${BUILDLINK_DIR}/bin/ruby; \
	fi

.endif	# RUBY_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
