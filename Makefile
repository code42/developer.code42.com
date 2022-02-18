BUILD = source
DOCS_SRC = docs-src
DOCS = $(DOCS_SRC)/docs
DOCS_OUT = $(DOCS_SRC)/out
API_DOCS = $(BUILD)/api
DOCS_SERVER = "https://api.us.code42.com"
BUILD_SCRIPTS = build-scripts

all:: clean html locations download transform definitions unify

run:: all serve

clean::
	$(BUILD_SCRIPTS)/clean.sh $(DOCS_SRC) $(BUILD) $(DOCS) $(DOCS_OUT)

locations::
	$(BUILD_SCRIPTS)/get_open_api_file_locations.sh $(DOCS_SERVER) $(DOCS_SRC)

download::
	$(BUILD_SCRIPTS)/download_open_api_files.sh $(DOCS_SRC) $(DOCS)

transform::
	$(BUILD_SCRIPTS)/transform.sh $(DOCS)

definitions::
	$(BUILD_SCRIPTS)/extract_open_api_paths_and_definitions.sh $(DOCS) $(DOCS_SRC)

unify::
	$(BUILD_SCRIPTS)/make_unified_open_api_doc.sh $(DOCS_SRC) $(DOCS_OUT) $(API_DOCS)

html::
	bundle exec middleman build

serve::
	bundle exec middleman serve

.PHONY:: all clean locations download transform definitions unify html serve
