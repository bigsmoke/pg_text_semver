EXTENSION = pg_text_semver

DISTVERSION = $(shell sed -n -E "/default_version/ s/^.*'(.*)'.*$$/\1/p" $(EXTENSION).control)

DATA = $(wildcard sql/$(EXTENSION)--*.sql)

REGRESS = test_extension_update_paths

PG_CONFIG ?= pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

# Set some environment variables for the regression tests that will be fed to `pg_regress`:
installcheck: export EXTENSION_NAME=$(EXTENSION)
installcheck: export EXTENSION_ENTRY_VERSIONS?=$(patsubst sql/$(EXTENSION)--%.sql,%,$(wildcard sql/$(EXTENSION)--[0-99].[0-99].[0-99].sql))

README.md: sql/README.sql install
	psql --quiet postgres < $< > $@

META.json: sql/META.sql install
	psql --quiet postgres < $< > $@

dist: META.json README.md
	git archive --format zip --prefix=$(EXTENSION)-$(DISTVERSION)/ -o $(EXTENSION)-$(DISTVERSION).zip HEAD
