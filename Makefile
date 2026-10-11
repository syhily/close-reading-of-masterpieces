PANDOC ?= pandoc
BUILD_DIR := build
EPUB := $(BUILD_DIR)/名作细读.epub
MANUSCRIPT := $(sort $(wildcard manuscript/*.md))

COVER := $(firstword $(wildcard assets/cover.jpg assets/cover.png))
ifneq ($(COVER),)
COVER_OPT := --epub-cover-image=$(COVER)
endif

.PHONY: build ocr clean

build: $(EPUB)

$(EPUB): metadata.yaml $(MANUSCRIPT) assets/epub.css $(COVER)
	@bash scripts/build.sh

ocr:
	@bash scripts/ocr.sh

clean:
	rm -rf $(BUILD_DIR)
