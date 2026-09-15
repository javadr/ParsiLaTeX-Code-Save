ADDON_NAME := parsilatex-code-save
SRC_DIR    := src
BUILD_DIR  := web-ext-artifacts
MANIFEST   := $(SRC_DIR)/manifest.json
VERSION    := $(shell python3 -c "import json; print(json.load(open('$(MANIFEST)'))['version'])")
XPI        := $(BUILD_DIR)/$(ADDON_NAME)-$(VERSION).xpi

SOURCES := $(SRC_DIR)/manifest.json \
           $(SRC_DIR)/sectoc.js \
           $(SRC_DIR)/sectoc.css \
           $(SRC_DIR)/jquery-3.3.1.min.js \
           $(SRC_DIR)/icons/icon48.png

.PHONY: all xpi lint build sign clean check help

all: xpi

# Default: package a Firefox-installable .xpi with plain `zip`
# (no npm / web-ext required). Excludes git metadata and build dir itself.
xpi: $(XPI)

$(XPI): $(SOURCES)
	mkdir -p $(BUILD_DIR)
	rm -f $(XPI)
	cd $(SRC_DIR) && zip -r -FS ../$(BUILD_DIR)/$(notdir $(XPI)) \
		manifest.json sectoc.js sectoc.css jquery-3.3.1.min.js icons
	@echo "Built $(XPI)"
	@unzip -l $(XPI)

# Validate file list + show what would be packaged
check:
	@for f in $(SOURCES); do test -f "$$f" || (echo "MISSING: $$f"; exit 1); done
	@echo "version: $(VERSION)"
	@echo "output:  $(XPI)"
	@python3 -c "import json; json.load(open('$(MANIFEST)')); print('manifest.json: valid JSON')"

# Requires: npm install --global web-ext
lint:
	command -v web-ext >/dev/null || (echo "web-ext not found: npm install --global web-ext"; exit 1)
	web-ext lint --source-dir=$(SRC_DIR)

build:
	command -v web-ext >/dev/null || (echo "web-ext not found: npm install --global web-ext"; exit 1)
	web-ext build --source-dir=$(SRC_DIR) --artifacts-dir=$(BUILD_DIR) --overwrite-dest

# Requires AMO credentials: make sign WEB_EXT_API_KEY=... WEB_EXT_API_SECRET=...
sign:
	command -v web-ext >/dev/null || (echo "web-ext not found: npm install --global web-ext"; exit 1)
	test -n "$(WEB_EXT_API_KEY)" || (echo "Set WEB_EXT_API_KEY (JWT issuer) e.g. make sign WEB_EXT_API_KEY=... WEB_EXT_API_SECRET=..."; exit 1)
	test -n "$(WEB_EXT_API_SECRET)" || (echo "Set WEB_EXT_API_SECRET (JWT secret)"; exit 1)
	web-ext sign --source-dir=$(SRC_DIR) --artifacts-dir=$(BUILD_DIR) \
		--api-key="$(WEB_EXT_API_KEY)" --api-secret="$(WEB_EXT_API_SECRET)"

clean:
	-rm -f $(BUILD_DIR)/$(ADDON_NAME)-*.xpi $(BUILD_DIR)/$(ADDON_NAME)-*.zip

help:
	@echo "Targets:"
	@echo "  make / make xpi   Build $(XPI) with plain zip (no deps)"
	@echo "  make check        Validate manifest + file list"
	@echo "  make lint         web-ext lint (needs web-ext)"
	@echo "  make build        web-ext build (needs web-ext)"
	@echo "  make sign WEB_EXT_API_KEY=.. WEB_EXT_API_SECRET=.."
	@echo "  make clean        Remove built xpi/zip artifacts"
