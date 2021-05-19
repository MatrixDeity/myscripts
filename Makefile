.DEFAULT_GOAL = help
SHELL = bash

ALIASES_FILE = $(HOME)/.bash_aliases
TARGET_CONFIGS_DIR = $(HOME)/.config/myscripts
TARGET_SCRIPTS_DIR = $(HOME)/.myscripts

MYSCRIPTS_BEGIN = \# myscripts section begin
MYSCRIPTS_LINE = source $(TARGET_SCRIPTS_DIR)/myscripts.sh
MYSCRIPTS_END = \# myscripts section end
MYSCRIPTS_ALL = $(MYSCRIPTS_BEGIN)\n$(MYSCRIPTS_LINE)\n$(MYSCRIPTS_END)

.PHONY: help
help:
	@echo -e "Available \e[33mmake\e[00m commands:\n"
	@echo -e "  \e[33mmake\e[00m            - the same as \e[33mmake help\e[00m."
	@echo -e "  \e[33mmake install\e[00m    - install scripts and configs on your system"
	@echo -e "                    (being executed a second time the command will"
	@echo -e "                    rewrite scripts but not existed configs)."
	@echo -e "  \e[33mmake uninstall\e[00m  - uninstall scripts and configs from your system."
	@echo -e "  \e[33mmake reinstall\e[00m  - alias for \e[33mmake uninstall install\e[00m (fully "
	@echo -e "                    rewrite scripts and configs)."
	@echo -e "  \e[33mmake help\e[00m       - show this help."
	@echo -e "\nSee README.md for additional information."

.PHONY: install
install:
	@echo -e "Install myscripts...\n"
	@echo -e "  Install scripts to \e[33m$(TARGET_SCRIPTS_DIR)\e[00m"
	@mkdir -p $(TARGET_SCRIPTS_DIR)
	@cp -r $(CURDIR)/scripts/* $(TARGET_SCRIPTS_DIR)
	@echo -e "  Update configs in \e[33m$(TARGET_CONFIGS_DIR)\e[00m"
	@mkdir -p $(TARGET_CONFIGS_DIR)
	@cp -rn $(CURDIR)/configs/* $(TARGET_CONFIGS_DIR)
	@echo -e "  Add myscripts aliases to \e[33m$(ALIASES_FILE)\e[00m"
	@grep -q "$(MYSCRIPTS_BEGIN)" $(ALIASES_FILE) 2>/dev/null || echo -e "$(MYSCRIPTS_ALL)" >> $(ALIASES_FILE)
	@echo -e "\n\e[32mDONE\e[00m"

.PHONY: uninstall
uninstall:
	@echo -e "Uninstall myscripts...\n"
	@echo -e "  Remove \e[33m$(TARGET_SCRIPTS_DIR)\e[00m"
	@rm -rf $(TARGET_SCRIPTS_DIR)
	@echo -e "  Remove \e[33m$(TARGET_CONFIGS_DIR)\e[00m"
	@rm -rf $(TARGET_CONFIGS_DIR)
	@echo -e "  Remove myscripts aliases from \e[33m$(ALIASES_FILE)\e[00m"
	@sed -i '/$(MYSCRIPTS_BEGIN)/,/$(MYSCRIPTS_END)/d' $(ALIASES_FILE)
	@echo -e "\n\e[32mDONE\e[00m"

.PHONY: reinstall
reinstall: uninstall install
