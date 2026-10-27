SRC_DIR := src
OUT_DIR := out
SOURCES := $(wildcard $(SRC_DIR)/*.md)
OUTPUTS := $(patsubst $(SRC_DIR)/%.md,$(OUT_DIR)/%.html,$(SOURCES))

node_modules: package-lock.json
	npm ci
	@touch node_modules

deps: node_modules

.PHONY: all check build test clean ci deps

all: test

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(OUT_DIR)/%.html: $(SRC_DIR)/%.md package-lock.json | $(OUT_DIR) node_modules
	@echo "  BUILD $< -> $@"
	@npm run --silent build -- $< $@

check:
	@if [ -z "$(SOURCES)" ]; then \
		echo "ERROR: no .md files found in $(SRC_DIR)"; \
		exit 1; \
	fi

build: $(OUTPUTS)

test: build
	@npm test --silent

clean:
	@rm -rf $(OUT_DIR)

ci: clean check test
