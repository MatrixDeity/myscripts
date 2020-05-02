ALIASES_FILE=$(HOME)/.bash_aliases
SOURCE_DIR=$(PWD)
TARGET_CONFIGS_DIR=$(HOME)/.config/myscripts
TARGET_SCRIPTS_DIR=$(HOME)/.myscripts

MYSCRIPTS_BEGIN=\# myscripts section begin
MYSCRIPTS_LINE=source $(TARGET_SCRIPTS_DIR)/myscripts.sh
MYSCRIPTS_END=\# myscripts section end
MYSCRIPTS_ALL=$(MYSCRIPTS_BEGIN)\n$(MYSCRIPTS_LINE)\n$(MYSCRIPTS_END)

.PHONY: all
all: install

.PHONY: install
install:
	@echo "Install myscripts...";
	@echo "  Install scripts to $(TARGET_SCRIPTS_DIR)";
	@mkdir -p $(TARGET_SCRIPTS_DIR);
	@cp -r $(SOURCE_DIR)/scripts/* $(TARGET_SCRIPTS_DIR);
	@echo "  Update configs in $(TARGET_CONFIGS_DIR)";
	@mkdir -p $(TARGET_CONFIGS_DIR);
	@cp -rn $(SOURCE_DIR)/configs/* $(TARGET_CONFIGS_DIR);
	@echo "  Add myscripts aliases to $(ALIASES_FILE)";
	@grep -q "$(MYSCRIPTS_BEGIN)" $(ALIASES_FILE) 2>/dev/null || echo "$(MYSCRIPTS_ALL)" >> $(ALIASES_FILE);
	@echo "DONE";

.PHONY: uninstall
uninstall:
	@echo "Uninstall myscripts...";
	@echo "  Remove $(TARGET_SCRIPTS_DIR)";
	@rm -rf $(TARGET_SCRIPTS_DIR);
	@echo "  Remove $(TARGET_CONFIGS_DIR)";
	@rm -rf $(TARGET_CONFIGS_DIR);
	@echo "  Remove myscripts aliases from $(ALIASES_FILE)";
	@sed -i '/$(MYSCRIPTS_BEGIN)/,/$(MYSCRIPTS_END)/d' $(ALIASES_FILE);
	@echo "DONE";

.PHONY: reinstall
reinstall: uninstall install
