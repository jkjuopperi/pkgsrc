# $NetBSD: buildlink3.mk,v 1.25 2006/01/06 15:08:47 wiz Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
DB4_BUILDLINK3_MK:=	${DB4_BUILDLINK3_MK}+

.include "../../mk/bsd.prefs.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	db4
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ndb4}
BUILDLINK_PACKAGES+=	db4

.if !empty(DB4_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.db4+=		db4>=4.4.16
BUILDLINK_PKGSRCDIR.db4?=	../../databases/db4
BUILDLINK_INCDIRS.db4?=		include/db4
BUILDLINK_LDADD.db4=		-ldb4
BUILDLINK_TRANSFORM+=		l:db-4:db4

.  if defined(USE_DB185) && !empty(USE_DB185:M[yY][eE][sS])
#
# Older db4 packages didn't enable the db-1.85 compatibility API.
#
BUILDLINK_DEPENDS.db4+=		db4>=4.2.52nb1
BUILDLINK_LIBS.db4=		${BUILDLINK_LDADD.db4}
BUILDLINK_TRANSFORM+=		l:db:db4
.  endif
.endif	# DB4_BUILDLINK3_MK

.include "../../mk/compiler.mk"
.if empty(PKGSRC_COMPILER:Mgcc)
PTHREAD_OPTS+=	native
.  include "../../mk/pthread.buildlink3.mk"
.endif

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
