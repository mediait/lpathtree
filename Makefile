# postgresql extension framework
# contrib/lpathtree/Makefile

MODULES = lpathtree
EXTENSION = lpathtree
DATA_built = lpathtree.sql
DOCS = README.lpathtree
MODULE_VERSION = 9.0
DATA = uninstall_lpathtree.sql
REGRESS = lpathtree
PG_CPPFLAGS = -DLOWER_NODE
MODULE_DIST = postgresql-lpathtree
MODULE_big = lpathtree
OBJS = 	lpathtree_io.o lpathtree_op.o lpathquery_op.o _lpathtree_op.o \
		crc32.o lpathtree_gist.o _lpathtree_gist.o

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
dist:
	mkdir -p $(MODULE_DIST)-$(MODULE_VERSION) && \
	cp --preserve=timestamps $(shell cat MANIFEST) $(MODULE_DIST)-$(MODULE_VERSION) && \
	tar cvzf $(MODULE_DIST)-$(MODULE_VERSION).tar.gz $(MODULE_DIST)-$(MODULE_VERSION) && \
	mv $(MODULE_DIST)-$(MODULE_VERSION).tar.gz .. && \
	rm -rf $(MODULE_DIST)-$(MODULE_VERSION)


