#	$NetBSD: Darwin.sys.mk,v 1.1.1.1 2004/03/11 13:03:59 grant Exp $
#	@(#)sys.mk	8.2 (Berkeley) 3/21/94

unix=		We run UNIX.
OS!=		uname -s

.SUFFIXES: .out .a .ln .o .s .S .c .cc .cpp .cxx .C .F .f .r .y .l .cl .p .h
.SUFFIXES: .sh .m4

.LIBS:		.a

AR?=		ar
ARFLAGS?=	rl
RANLIB?=	ranlib

AS?=		as
AFLAGS?=
COMPILE.s?=	${AS} ${AFLAGS}
LINK.s?=	${CC} ${AFLAGS} ${LDFLAGS}
COMPILE.S?=	${CC} ${AFLAGS} ${CPPFLAGS} -c
LINK.S?=	${CC} ${AFLAGS} ${CPPFLAGS} ${LDFLAGS}

.if exists(/usr/bin/gcc)
CC?=		gcc -pipe
.else
CC?=		cc -pipe
.endif
DBG?=		-O2
CFLAGS?=	${DBG}
COMPILE.c?=	${CC} ${CFLAGS} ${CPPFLAGS} -c
LINK.c?=	${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}

.if exists(/usr/bin/g++)
CXX?=		g++
.else
CXX?=		c++
.endif
CXXFLAGS?=	${CFLAGS}
COMPILE.cc?=	${CXX} ${CXXFLAGS} ${CPPFLAGS} -c
LINK.cc?=	${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}

OBJC?=		${CC}
OBJCFLAGS?=	${CFLAGS}
COMPILE.m?=	${OBJC} ${OBJCFLAGS} ${CPPFLAGS} -c
LINK.m?=	${OBJC} ${OBJCFLAGS} ${CPPFLAGS} ${LDFLAGS}

CPP?=		cpp
NOLINT=		1
CPPFLAGS?=

MK_DEP?=	mkdeps.sh -N

FC?=		f77
FFLAGS?=	-O
RFLAGS?=
COMPILE.f?=	${FC} ${FFLAGS} -c
LINK.f?=	${FC} ${FFLAGS} ${LDFLAGS}
COMPILE.F?=	${FC} ${FFLAGS} ${CPPFLAGS} -c
LINK.F?=	${FC} ${FFLAGS} ${CPPFLAGS} ${LDFLAGS}
COMPILE.r?=	${FC} ${FFLAGS} ${RFLAGS} -c
LINK.r?=	${FC} ${FFLAGS} ${RFLAGS} ${LDFLAGS}

INSTALL?=	install

LEX?=		lex
LFLAGS?=
LEX.l?=		${LEX} ${LFLAGS}

LD?=		ld
LDFLAGS?=

LINT?=		lint
LINTFLAGS?=	-chapbx

LORDER?=	lorder

MAKE?=		bmake

NM?=		nm

PC?=		pc
PFLAGS?=
COMPILE.p?=	${PC} ${PFLAGS} ${CPPFLAGS} -c
LINK.p?=	${PC} ${PFLAGS} ${CPPFLAGS} ${LDFLAGS}

SHELL?=		sh

SIZE?=		size

TSORT?=		tsort -q

YACC?=		yacc
YFLAGS?=	-d
YACC.y?=	${YACC} ${YFLAGS}

# C
.c:
	${LINK.c} -o ${.TARGET} ${.IMPSRC} ${LDLIBS}
.c.o:
	${COMPILE.c} ${.IMPSRC}
.c.a:
	${COMPILE.c} ${.IMPSRC}
	${AR} ${ARFLAGS} $@ $*.o
	rm -f $*.o

# C++
.cc:
	${LINK.cc} -o ${.TARGET} ${.IMPSRC} ${LDLIBS}
.cc.o:
	${COMPILE.cc} ${.IMPSRC}
.cc.a:
	${COMPILE.cc} ${.IMPSRC}
	${AR} ${ARFLAGS} $@ $*.o
	rm -f $*.o

.C:
	${LINK.cc} -o ${.TARGET} ${.IMPSRC} ${LDLIBS}
.C.o:
	${COMPILE.cc} ${.IMPSRC}
.C.a:
	${COMPILE.cc} ${.IMPSRC}
	${AR} ${ARFLAGS} $@ $*.o
	rm -f $*.o

# Fortran/Ratfor
.f:
	${LINK.f} -o ${.TARGET} ${.IMPSRC} ${LDLIBS}
.f.o:
	${COMPILE.f} ${.IMPSRC}
.f.a:
	${COMPILE.f} ${.IMPSRC}
	${AR} ${ARFLAGS} $@ $*.o
	rm -f $*.o

.F:
	${LINK.F} -o ${.TARGET} ${.IMPSRC} ${LDLIBS}
.F.o:
	${COMPILE.F} ${.IMPSRC}
.F.a:
	${COMPILE.F} ${.IMPSRC}
	${AR} ${ARFLAGS} $@ $*.o
	rm -f $*.o

.r:
	${LINK.r} -o ${.TARGET} ${.IMPSRC} ${LDLIBS}
.r.o:
	${COMPILE.r} ${.IMPSRC}
.r.a:
	${COMPILE.r} ${.IMPSRC}
	${AR} ${ARFLAGS} $@ $*.o
	rm -f $*.o

# Pascal
.p:
	${LINK.p} -o ${.TARGET} ${.IMPSRC} ${LDLIBS}
.p.o:
	${COMPILE.p} ${.IMPSRC}
.p.a:
	${COMPILE.p} ${.IMPSRC}
	${AR} ${ARFLAGS} $@ $*.o
	rm -f $*.o

# Assembly
.s:
	${LINK.s} -o ${.TARGET} ${.IMPSRC} ${LDLIBS}
.s.o:
	${COMPILE.s} -o ${.TARGET} ${.IMPSRC} 
.s.a:
	${COMPILE.s} ${.IMPSRC}
	${AR} ${ARFLAGS} $@ $*.o
	rm -f $*.o
.S:
	${LINK.S} -o ${.TARGET} ${.IMPSRC} ${LDLIBS}
.S.o:
	${COMPILE.S} ${.IMPSRC}
.S.a:
	${COMPILE.S} ${.IMPSRC}
	${AR} ${ARFLAGS} $@ $*.o
	rm -f $*.o

# Lex
.l:
	${LEX.l} ${.IMPSRC}
	${LINK.c} -o ${.TARGET} lex.yy.c ${LDLIBS} -ll
	rm -f lex.yy.c
.l.c:
	${LEX.l} ${.IMPSRC}
	mv lex.yy.c ${.TARGET}
.l.o:
	${LEX.l} ${.IMPSRC}
	${COMPILE.c} -o ${.TARGET} lex.yy.c 
	rm -f lex.yy.c

# Yacc
.y:
	${YACC.y} ${.IMPSRC}
	${LINK.c} -o ${.TARGET} y.tab.c ${LDLIBS}
	rm -f y.tab.c
.y.c:
	${YACC.y} ${.IMPSRC}
	mv y.tab.c ${.TARGET}
.y.o:
	${YACC.y} ${.IMPSRC}
	${COMPILE.c} -o ${.TARGET} y.tab.c
	rm -f y.tab.c

# Shell
.sh:
	rm -f ${.TARGET}
	cp ${.IMPSRC} ${.TARGET}
