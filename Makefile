BUILD = source
DOCS_SRC = docs-src
DOCS = $(DOCS_SRC)/docs
DOCS_OUT = $(DOCS_SRC)/out
API_DOCS = $(BUILD)/api
DOCS_SERVER = "https://api.us.code42.com"
BUILD_SCRIPTS = build-scripts

all:: clean docs html locations download transform definitions unify

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

docs::
	mdmerge -o source/api/user_guides.rmd \
	source/api/user-guides/user_guides.rmd \
	source/api/user-guides/get_started.rmd \
	source/api/user-guides/manage_alerts.rmd \
	source/api/user-guides/manage_cases.rmd \
	source/api/user-guides/manage_users.rmd \
	source/api/user-guides/manage_watchlists.rmd \
	source/api/user-guides/search_file_events.rmd \
	source/api/user-guides/use_case_alerts.rmd \
	source/api/user-guides/use_case_high_risk_employee.rmd

.PHONY:: all clean locations download transform definitions unify html serve docs
