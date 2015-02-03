# contrib/lpathtree/Makefile

MODULE_big = lpathtree
OBJS = 	lpathtree_io.o lpathtree_op.o lpathquery_op.o _lpathtree_op.o crc32.o \
	lpathtree_gist.o _lpathtree_gist.o
PG_CPPFLAGS = -DLOWER_NODE

EXTENSION = lpathtree
DATA = lpathtree--1.0.sql lpathtree--unpackaged--1.0.sql

REGRESS = lpathtree

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/lpathtree
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
