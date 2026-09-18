ADDON_NAME := parsilatex-code-save
SRC_DIR    := src
BUILD_DIR  := web-ext-artifacts
MANIFEST   := $(SRC_DIR)/manifest.json
VERSION    := $(shell python3 -c "import json; print(json.load(open('$(MANIFEST)'))['version'])")
XPI         := $(BUILD_DIR)/$(ADDON_NAME)-$(VERSION).xpi
SOURCE_ZIP  := $(BUILD_DIR)/$(ADDON_NAME)-$(VERSION)-source.zip

SOURCES := $(SRC_DIR)/manifest.json \
           $(SRC_DIR)/sectoc.js \
           $(SRC_DIR)/sectoc.css \
           $(SRC_DIR)/jquery-3.3.1.min.js \
           $(SRC_DIR)/icons/icon48.png

SOURCE_FILES := $(SOURCES) \
           README.md \
           LICENSE \
           Makefile

.PHONY: all xpi source lint build sign clean check help

all: xpi source

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

# Source archive required by AMO when shipping minified code (jquery).
# Keeps the repo layout (src/ + root docs) so reviewers can follow it.
source: $(SOURCE_ZIP)

$(SOURCE_ZIP): $(SOURCE_FILES)
	mkdir -p $(BUILD_DIR)
	rm -f $(SOURCE_ZIP)
	zip -r -FS $(SOURCE_ZIP) $(SOURCE_FILES)
	@echo "Built $(SOURCE_ZIP)"
	@unzip -l $(SOURCE_ZIP)

# Validate file list + show what would be packaged
check:
	@for f in $(SOURCE_FILES); do test -f "$$f" || (echo "MISSING: $$f"; exit 1); done
	@echo "version: $(VERSION)"
	@echo "xpi:     $(XPI)"
	@echo "source:  $(SOURCE_ZIP)"
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
	@echo "  make / make all     Build $(XPI) and $(SOURCE_ZIP)"
	@echo "  make xpi            Build $(XPI) with plain zip (no deps)"
	@echo "  make source         Build $(SOURCE_ZIP) for AMO source review"
	@echo "  make check          Validate manifest + file list"
	@echo "  make lint           web-ext lint (needs web-ext)"
	@echo "  make build          web-ext build (needs web-ext)"
	@echo "  make sign WEB_EXT_API_KEY=.. WEB_EXT_API_SECRET=.."
	@echo "  make clean          Remove built xpi/zip artifacts"
