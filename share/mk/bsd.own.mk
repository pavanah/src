#	$OpenBSD: bsd.own.mk,v 1.126 2012/09/01 03:12:16 deraadt Exp $
#	$NetBSD: bsd.own.mk,v 1.24 1996/04/13 02:08:09 thorpej Exp $

# Host-specific overrides
.if defined(MAKECONF) && exists(${MAKECONF})
.include "${MAKECONF}"
.elif exists(/etc/mk.conf)
.include "/etc/mk.conf"
.endif

# Set `WARNINGS' to `yes' to add appropriate warnings to each compilation
WARNINGS?=	no
# Set `SKEY' to `yes' to build with support for S/key authentication.
SKEY?=		yes
# Set `KERBEROS5' to `yes' to build with support for Kerberos5 authentication.
KERBEROS5?=	yes
# Set `YP' to `yes' to build with support for NIS/YP.
YP?=		yes
# Set `TCP_WRAPPERS' to `yes' to build certain networking daemons with
# integrated support for libwrap.
TCP_WRAPPERS?=	yes
# Set `DEBUGLIBS' to `yes' to build libraries with debugging symbols
DEBUGLIBS?=	no
# Set toolchain to be able to know differences.
.if ${MACHINE_ARCH} == "m68k" || ${MACHINE_ARCH} == "m88k" || \
    ${MACHINE_ARCH} == "vax"
ELF_TOOLCHAIN?=	no
.else
ELF_TOOLCHAIN?=	yes
.endif

GCC2_ARCH=m68k m88k vax
GCC4_ARCH=alpha amd64 arm hppa hppa64 i386 ia64 mips64 mips64el powerpc sparc sparc64 sh
BINUTILS217_ARCH=hppa64 ia64
PIE_ARCH=amd64 mips64 mips64el sparc64

.for _arch in ${MACHINE_ARCH}
.if !empty(GCC2_ARCH:M${_arch})
COMPILER_VERSION?=gcc2
.elif !empty(GCC4_ARCH:M${_arch})
COMPILER_VERSION?=gcc4
.else
COMPILER_VERSION?=gcc3
.endif

.if !empty(BINUTILS217_ARCH:M${_arch})
BINUTILS_VERSION=binutils-2.17
.else
BINUTILS_VERSION=binutils
.endif

.if !empty(PIE_ARCH:M${_arch})
NOPIE_FLAGS=-fno-pie
NOPIE_LDFLAGS=-nopie
PIE_DEFAULT=${DEFAULT_PIE_DEF}
.else
NOPIE_FLAGS=
PIE_DEFAULT=
.endif
.endfor

.if ${COMPILER_VERSION} == "gcc4"
VISIBILITY_HIDDEN?=-fvisibility=hidden
.endif

# where the system object and source trees are kept; can be configurable
# by the user in case they want them in ~/foosrc and ~/fooobj, for example
BSDSRCDIR?=	/usr/src
BSDOBJDIR?=	/usr/obj

BINGRP?=	bin
BINOWN?=	root
BINMODE?=	555
NONBINMODE?=	444
DIRMODE?=	755

SHAREDIR?=	/usr/share
SHAREGRP?=	bin
SHAREOWN?=	root
SHAREMODE?=	${NONBINMODE}

MANDIR?=	/usr/share/man/man
MANGRP?=	bin
MANOWN?=	root
MANMODE?=	${NONBINMODE}

LIBDIR?=	/usr/lib
LIBGRP?=	${BINGRP}
LIBOWN?=	${BINOWN}
LIBMODE?=	${NONBINMODE}

DOCDIR?=	/usr/share/doc
DOCGRP?=	bin
DOCOWN?=	root
DOCMODE?=	${NONBINMODE}

LKMDIR?=	/usr/lkm
LKMGRP?=	${BINGRP}
LKMOWN?=	${BINOWN}
LKMMODE?=	${NONBINMODE}

NLSDIR?=	/usr/share/nls
NLSGRP?=	bin
NLSOWN?=	root
NLSMODE?=	${NONBINMODE}

LOCALEDIR?=	/usr/share/locale
LOCALEGRP?=	wheel
LOCALEOWN?=	root
LOCALEMODE?=	${NONBINMODE}

.if !defined(CDIAGFLAGS)
CDIAGFLAGS=	-Wall -Wpointer-arith -Wuninitialized -Wstrict-prototypes
CDIAGFLAGS+=	-Wmissing-prototypes -Wunused -Wsign-compare -Wbounded
CDIAGFLAGS+=	-Wshadow
.  if ${COMPILER_VERSION} == "gcc4"
CDIAGFLAGS+=	-Wdeclaration-after-statement
.  endif
.endif

# Shared files for system gnu configure, not used yet
GNUSYSTEM_AUX_DIR?=${BSDSRCDIR}/share/gnu

INSTALL_COPY?=	-c
.ifndef DEBUG
INSTALL_STRIP?=	-s
.endif

# This may be changed for _single filesystem_ configurations (such as
# routers and other embedded systems); normal systems should leave it alone!
STATIC?=	-static

# Define SYS_INCLUDE to indicate whether you want symbolic links to the system
# source (``symlinks''), or a separate copy (``copies''); (latter useful
# in environments where it's not possible to keep /sys publicly readable)
#SYS_INCLUDE= 	symlinks

# don't try to generate PIC versions of libraries on machines
# which don't support PIC.
.if ${MACHINE_ARCH} == "m88k" || ${MACHINE_ARCH} == "vax"
NOPIC=
.endif

# pic relocation flags.
.if (${MACHINE_ARCH} == "alpha") || (${MACHINE_ARCH} == "sparc64")
PICFLAG?=-fPIC
.else
PICFLAG?=-fpic
. if ${MACHINE_ARCH} == "m68k"
# Function CSE makes gas -k not recognize external function calls as lazily
# resolvable symbols, thus sometimes making ld.so report undefined symbol
# errors on symbols found in shared library members that would never be
# called.  Ask niklas@openbsd.org for details.
PICFLAG+=-fno-function-cse
. endif
.endif

.if ${MACHINE_ARCH} == "sparc" || ${MACHINE_ARCH} == "sparc64"
ASPICFLAG=-KPIC
.elif ${ELF_TOOLCHAIN:L} == "no"
ASPICFLAG=-k
.endif

.if ${MACHINE_ARCH} == "alpha" || ${MACHINE_ARCH} == "sparc64"
# big PIE
DEFAULT_PIE_DEF=-DPIE_DEFAULT=2
.else
# small pie
DEFAULT_PIE_DEF=-DPIE_DEFAULT=1
.endif

# don't try to generate PROFILED versions of libraries on machines
# which don't support profiling.
.if 0
NOPROFILE=
.endif

BSD_OWN_MK=Done

.PHONY: spell clean cleandir obj manpages print all \
	depend beforedepend afterdepend cleandepend subdirdepend \
	all cleanman nlsinstall cleannls includes \
	beforeinstall realinstall maninstall afterinstall install
