REBAR = rebar3
BUILD_DIR = _build/Erlang
DEFAULT_DIR = _build/default
PRIV_DIR = priv
FORMATTERS_DIR = ~/.rdm/formatters
MKDIR = mkdir
CP = cp


.PHONY: build install escriptize compile get-deps clean

build: escriptize
	$(MKDIR) -p $(BUILD_DIR)
	$(CP) -rf $(DEFAULT_DIR)/bin/rdm_erlang $(BUILD_DIR)
	$(CP) -rf $(PRIV_DIR)/usage.json $(BUILD_DIR)

install: build
	$(MKDIR) -p $(FORMATTERS_DIR)
	$(CP) -rf $(BUILD_DIR) $(FORMATTERS_DIR)

escriptize: compile
	$(REBAR) escriptize

compile: get-deps
	$(REBAR) compile

get-deps:
	$(REBAR) get-deps

clean:
	$(REBAR) clean -a
	$(RM) -r $(BUILD_DIR)

test:
	$(REBAR) eunit
