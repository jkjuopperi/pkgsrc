# $NetBSD: Makefile,v 1.5 2011/08/14 14:42:47 obache Exp $
#

DISTNAME=		Crypt-Eksblowfish-0.008
PKGNAME=		p5-${DISTNAME}
PKGREVISION=		2
CATEGORIES=		security perl5
MASTER_SITES=		${MASTER_SITE_PERL_CPAN:=Crypt/}

MAINTAINER=		pkgsrc-users@NetBSD.org
HOMEPAGE=		http://search.cpan.org/dist/Crypt-Eksblowfish/
COMMENT=		Perl5 Eksblowfish block cipher
LICENSE=		${PERL5_LICENSE}

DEPENDS+=		p5-Class-Mix>=0.001:../../devel/p5-Class-Mix
DEPENDS+=		{perl>=5.10.1,p5-parent-[0-9]*}:../../devel/p5-parent
DEPENDS+=		{perl>=5.8.2,p5-MIME-Base64>=2.21}:../../converters/p5-MIME-Base64
BUILD_DEPENDS+=		{perl>=5.10.0,p5-ExtUtils-CBuilder>=0.15}:../../devel/p5-ExtUtils-CBuilder

PKG_DESTDIR_SUPPORT=	user-destdir
PKG_INSTALLATION_TYPES=	overwrite pkgviews

CRYPTO=			YES
USE_LANGUAGES=		c
PERL5_MODULE_TYPE=	Module::Build
PERL5_PACKLIST=		auto/Crypt/Eksblowfish/.packlist

.include "../../lang/perl5/module.mk"
.include "../../mk/bsd.pkg.mk"
