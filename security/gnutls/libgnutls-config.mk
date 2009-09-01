# $NetBSD: libgnutls-config.mk,v 1.2 2009/09/01 17:48:14 joerg Exp $

# Makefile intended to be included by packages that need "libgnutls-config"
# during build time.

USE_TOOLS+=	pkg-config

pre-configure: hack-libgnutls-config

hack-libgnutls-config:
	${PRINTF} "#! ${SH}\\n\
	  case \$$1 in\\n\
	  --cflags|--libs) pkg-config \$$1 gnutls;;\\n\
	  --version) pkg-config --modversion gnutls;;\\n\
	  *) exit 1;;\\n\
	  esac\\n\
	" > ${BUILDLINK_DIR}/bin/libgnutls-config
	${CHMOD} +x ${BUILDLINK_DIR}/bin/libgnutls-config
