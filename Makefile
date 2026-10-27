SRC_DIR := src
OUT_DIR := out
SOURCES := $(wildcard $(SRC_DIR)/*.md)
OUTPUTS := $(patsubst $(SRC_DIR)/%.md,$(OUT_DIR)/%.html,$(SOURCES))

.PHONY: all check build test clean ci help deps package

all: test  ## build and test everything (default)

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

node_modules: package-lock.json
	npm ci
	@touch node_modules

deps: node_modules  ## install exactly what the lock file says

$(OUT_DIR)/%.html: $(SRC_DIR)/%.md package-lock.json | $(OUT_DIR) node_modules
	@echo "  BUILD $< -> $@"
	@npm run --silent build -- $< $@

check:  ## fail early if there is nothing to build
	@test -d $(SRC_DIR) || { echo "ERROR: source directory $(SRC_DIR) not found"; exit 1; }
	@test -n "$(SOURCES)" || { echo "ERROR: no .md files found in $(SRC_DIR)"; exit 1; }
	@echo "check: $(words $(SOURCES)) source file(s) in $(SRC_DIR)"

build: $(OUTPUTS)  ## build every out-of-date output

test: build  ## run the test suite against what was built
	@npm test --silent

package: test  ## produce the versioned artifact
	npm pack

clean:  ## remove all generated files
	rm -rf $(OUT_DIR) *.tgz

ci: clean deps check test package  ## the build server entry point

help:  ## show this help
	@grep -E '^[a-z][a-zA-Z_-]*:.*?## ' $(MAKEFILE_LIST) \
	 | sed 's/:.*## /\t/' | column -t -s "$$(printf '\t')"
