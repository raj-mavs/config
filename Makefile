.PHONY: lua scripts system-packages

SHELL := /bin/sh
.DEFAULT-GOAL: help


# Colors 
RESET = \e[0m
RED = \e[31m
GREEN = \e[32m
YELLOW = \e[33m
CYAN = \e[36m
MAGNETA = \e[35m

# Input directory
BASHRC = $(HOME)/.bashrc
REM = $(HOME)/.config/remind

# Output directory
BACKUP_DIR = system-packages
REM_DIR = remind

define color
$(1)$(2)$(RESET)
endef

help:
	@echo -e "$(call color,$(YELLOW),Makefile Help)"
	@echo -e "$(call color,$(CYAN),    init                   Initialize the folder(s) required)"
	@echo -e "$(call color,$(CYAN),    bashrc                 Load the .bashrc from the $(call color,$(MAGNETA),$(HOME)))"
	@echo -e "$(call color,$(CYAN),    rem                    Load the .rem scrips from the $(call color,$(MAGNETA),$(REM)))"
	@echo -e "$(call color,$(CYAN),    package-update         Update the system packages)"
	@echo -e "$(call color,$(CYAN),    all                    Does all the above)"

all: init bashrc rem package-update

init:
	@mkdir -p $(BACKUP_DIR)
	@mkdir -p $(REM_DIR)

bashrc:
	@cp $(HOME)/.bashrc .bashrc
	@echo -e "$(call color,$(GREEN),.bashrc load from $(call color,$(YELLOW),$(BASHRC)))"

rem:
	@cp $(REM)/*.rem $(REM_DIR)
	@echo -e "$(call color,$(GREEN),all .rem scripted loaded from $(call color,$(YELLOW),$(REM)))"

package-update:
	@pacman -Qen > $(BACKUP_DIR)/requirements.txt
	@pacman -Qem > $(BACKUP_DIR)/aur_requirements.txt || true
	@echo -e "$(call color,$(GREEN),Package lists successfully updated in $(call color,$(YELLOW),$(BACKUP_DIR)))" 

