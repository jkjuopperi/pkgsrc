# $NetBSD: rails.mk,v 1.6 2011/06/11 03:04:22 taca Exp $

.if !defined(_RUBY_RAILS_MK)
_RUBY_RAILS_MK=	# defined

#
# === User-settable variables ===
#
# RUBY_RAILS_DEFAULT
#	Select default Ruby on Rails version.
#
#	Possible values: 2 3
#	Default: 2
#
#
# === Package-settable variables ===
#
# RUBY_RAILS
#	Force sepecify RUBY_RAILS_DEFAULT.  It is only for packages of
#	rails components.
#
#	Possible values: 2 3 (empty)
#

#
# current Ruby on Rails versions.
#
RUBY_RAILS2_VERSION?=	2.3.12
RUBY_RAILS3_VERSION?=	3.0.8

.if !empty(RUBY_RAILS)
RUBY_RAILS_DEFAULT=		${RUBY_RAILS}
_RUBY_RAILS_DEPENDS_EXACT=	yes
.endif

.if empty(RUBY_RAILS_DEFAULT)
_RUBY_INSTALLED_RAILS!= \
	if ${PKG_INFO} -qe "${RUBY_PKGPREFIX}-rack>=1.2" || \
		${PKG_INFO} -qe "${RUBY_PKGPREFIX}-activesupport>=3.0"; then \
		${ECHO} 3; \
	elif ${PKG_INFO} -qe "${RUBY_PKGPREFIX}-rack<1.2" || \
		${PKG_INFO} -qe "${RUBY_PKGPREFIX}-activesupport<3"; then \
		${ECHO} 2; \
	else \
		${ECHO} "none"; \
	fi
. if ${_RUBY_INSTALLED_RAILS} != "none"
RUBY_RAILS_DEFAULT:=	${_RUBY_INSTALLED_RAILS}
. endif
.endif

RUBY_RAILS_DEFAULT?=	2
.if ${RUBY_RAILS_DEFAULT} == "2"
RUBY_RAILS_VERSION:=	${RUBY_RAILS2_VERSION}
_RUBY_RAILS_MAJOR=	2
.else
RUBY_RAILS_VERSION:=	${RUBY_RAILS3_VERSION}
_RUBY_RAILS_MAJOR=	3
.endif

#
MULTI+=			RUBY_RAILS_DEFAULT=${RUBY_RAILS_DEFAULT}

#
# _
#	If defined, match exact version.  Otherwise allow greater minor version.
#
.if empty(_RUBY_RAILS_DEPENDS_EXACT)
_RUBY_RAILS_NEXT!=	${EXPR} ${_RUBY_RAILS_MAJOR} + 1
_RAILS_DEP=		>=${RUBY_RAILS_VERSION}<${_RUBY_RAILS_NEXT}
.else
_RUBY_RAILS_VERS=   ${RUBY_RAILS_VERSION:C/([0-9]+)\.([0-9]+)\.([0-9]+)/\1.\2/}
_RUBY_RAILS_TEENY=  ${RUBY_RAILS_VERSION:C/([0-9]+)\.([0-9]+)\.([0-9]+)/\3/}

_RUBY_RAILS_NEXT!=	${EXPR} ${_RUBY_RAILS_TEENY} + 1
_RAILS_DEP=		>=${RUBY_RAILS_VERSION}<${_RUBY_RAILS_VERS}.${_RUBY_RAILS_NEXT}
.endif

RUBY_ACTIVESUPPORT?=	${RUBY_RAILS_VERSION}
RUBY_ACTIONPACK?=	${RUBY_RAILS_VERSION}
RUBY_ACTIVERECORD?=	${RUBY_RAILS_VERSION}
RUBY_ACTIVERESOURCE?=	${RUBY_RAILS_VERSION}
RUBY_ACTIONMAILER?=	${RUBY_RAILS_VERSION}
RUBY_RAILTIES?=		${RUBY_RAILS_VERSION}

RUBY_RAILS2_ACTIVESUPPORT=	../../devel/ruby-activesupport
RUBY_RAILS2_ACTIONPACK=		../../www/ruby-actionpack
RUBY_RAILS2_ACTIVERECORD=	../../databases/ruby-activerecord
RUBY_RAILS2_ACTIVERESOURCE=	../../www/ruby-activeresource
RUBY_RAILS2_ACTIONMAILER=	../../mail/ruby-actionmailer
RUBY_RAILS2_RAILS=		../../www/ruby-rails

RUBY_RAILS3_ACTIVESUPPORT=	../../devel/ruby-activesupport3
RUBY_RAILS3_ACTIVEMODEL=	../../devel/ruby-activemodel
RUBY_RAILS3_ACTIONPACK=		../../www/ruby-actionpack3
RUBY_RAILS3_ACTIVERECORD=	../../databases/ruby-activerecord3
RUBY_RAILS3_ACTIVERESOURCE=	../../www/ruby-activeresource3
RUBY_RAILS3_ACTIONMAILER=	../../mail/ruby-actionmailer3
RUBY_RAILS3_RAILTIES=		../../devel/ruby-railties
RUBY_RAILS3_RAILS=		../../www/ruby-rails3

.if ${_RUBY_RAILS_MAJOR} == "2"
RUBY_ACTIVESUPPORT_DEPENDS= \
	${RUBY_PKGPREFIX}-activesupport${_RAILS_DEP}:${RUBY_RAILS2_ACTIVESUPPORT}
RUBY_ACTIONPACK_DEPENDS= \
	${RUBY_PKGPREFIX}-actionpack${_RAILS_DEP}:${RUBY_RAILS2_ACTIONPACK}
RUBY_ACTIVERECORD_DEPENDS= \
	${RUBY_PKGPREFIX}-activerecord${_RAILS_DEP}:${RUBY_RAILS2_ACTIVERECORD}
RUBY_ACTIVERESOURCE_DEPENDS= \
	${RUBY_PKGPREFIX}-activeresource${_RAILS_DEP}:${RUBY_RAILS2_ACTIVERESOURCE}
RUBY_ACTIONMAILER_DEPENDS= \
	${RUBY_PKGPREFIX}-actionmailer${_RAILS_DEP}:${RUBY_RAILS2_ACTIONMAILER}
RUBY_RAILTIES_DEPENDS= # empty
RUBY_RAILTIES_DEPENDS= # empty
RUBY_RAILS_DEPENDS= \
	${RUBY_PKGPREFIX}-rails${_RAILS_DEP}:${RUBY_RAILS2_RAILS}
.else
RUBY_ACTIVESUPPORT_DEPENDS= \
	${RUBY_PKGPREFIX}-activesupport${_RAILS_DEP}:${RUBY_RAILS3_ACTIVESUPPORT}
RUBY_ACTIVEMODEL_DEPENDS= \
	${RUBY_PKGPREFIX}-activemodel${_RAILS_DEP}:${RUBY_RAILS3_ACTIVEMODEL}
RUBY_ACTIONPACK_DEPENDS= \
	${RUBY_PKGPREFIX}-actionpack${_RAILS_DEP}:${RUBY_RAILS3_ACTIONPACK}
RUBY_ACTIVERECORD_DEPENDS= \
	${RUBY_PKGPREFIX}-activerecord${_RAILS_DEP}:${RUBY_RAILS3_ACTIVERECORD}
RUBY_ACTIVERESOURCE_DEPENDS= \
	${RUBY_PKGPREFIX}-activeresource${_RAILS_DEP}:${RUBY_RAILS3_ACTIVERESOURCE}
RUBY_ACTIONMAILER_DEPENDS= \
	${RUBY_PKGPREFIX}-actionmailer${_RAILS_DEP}:${RUBY_RAILS3_ACTIONMAILER}
RUBY_RAILTIES_DEPENDS= \
	${RUBY_PKGPREFIX}-railties${_RAILS_DEP}:${RUBY_RAILS3_RAILTIES}
RUBY_RAILS_DEPENDS= \
	${RUBY_PKGPREFIX}-rails${_RAILS_DEP}:${RUBY_RAILS3_RAILS}
.endif

.endif
