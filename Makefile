# ==============================================================================
# check-cert Makefile
# ==============================================================================

SCRIPT_NAME  = check-cert
SCRIPT_FILE  = check_cert_key_match
MAN_FILE     = check-cert.1
INSTALL_DIR  = /usr/local/bin
MAN_DIR      = /usr/share/man/man1
VERSION      = $(shell grep '^VERSION=' $(SCRIPT_FILE) | cut -d'"' -f2)

# ------------------------------------------------------------------------------
# OS detection via /etc/os-release
# Reads ID and ID_LIKE to cover derivatives (e.g. AlmaLinux → rhel)
# Resolves OS_FAMILY to: debian | rhel | unknown
# ------------------------------------------------------------------------------
OS_RAW    := $(shell . /etc/os-release 2>/dev/null && printf '%s %s' "$$ID" "$$ID_LIKE" | tr '[:upper:]' '[:lower:]')
IS_DEBIAN := $(shell echo "$(OS_RAW)" | grep -qE 'debian|ubuntu' && echo yes || echo no)
IS_RHEL   := $(shell echo "$(OS_RAW)" | grep -qE 'rhel|fedora|centos|almalinux|rocky' && echo yes || echo no)

ifeq ($(IS_DEBIAN),yes)
    OS_FAMILY   = debian
    PKG_INSTALL = sudo apt-get install -y
    BATS_PKG    = bats
    SC_PKG      = shellcheck
    PKG_PREP    =
else ifeq ($(IS_RHEL),yes)
    OS_FAMILY   = rhel
    PKG_INSTALL = sudo dnf install -y
    BATS_PKG    = bats
    SC_PKG      = ShellCheck
    PKG_PREP    = sudo dnf install -y epel-release &&
else
    OS_FAMILY   = unknown
    PKG_INSTALL = echo "Unsupported OS — please install manually:"
    BATS_PKG    = bats
    SC_PKG      = shellcheck
    PKG_PREP    =
endif

.PHONY: all install uninstall clean test lint deps

# ------------------------------------------------------------------------------
all:
	@echo "check-cert v$(VERSION)  [OS family: $(OS_FAMILY)]"
	@echo ""
	@echo "Available targets:"
	@echo "  install    — Install script and man page"
	@echo "  uninstall  — Remove installed files"
	@echo "  deps       — Install bats + shellcheck for this OS"
	@echo "  test       — Run bats test suite"
	@echo "  lint       — Run shellcheck"
	@echo "  clean      — Remove generated files"

# ------------------------------------------------------------------------------
install: $(SCRIPT_FILE)
	@echo "Installing check-cert v$(VERSION)..."
	sudo cp $(SCRIPT_FILE) $(INSTALL_DIR)/$(SCRIPT_NAME)
	sudo chmod +x $(INSTALL_DIR)/$(SCRIPT_NAME)
	@if [ -f "$(MAN_FILE)" ]; then \
		echo "Installing man page..."; \
		gzip -kf $(MAN_FILE); \
		sudo cp $(MAN_FILE).gz $(MAN_DIR)/$(MAN_FILE).gz; \
		sudo mandb -q; \
	else \
		echo "⚠️  Man page not found, skipping."; \
	fi
	@echo "✅ Installed! Run: check-cert --help"

# ------------------------------------------------------------------------------
uninstall:
	@echo "Removing check-cert..."
	sudo rm -f $(INSTALL_DIR)/$(SCRIPT_NAME)
	sudo rm -f $(MAN_DIR)/$(MAN_FILE).gz
	sudo mandb -q
	@echo "✅ Uninstalled."

# ------------------------------------------------------------------------------
# Install test/lint dependencies for the detected OS
# ------------------------------------------------------------------------------
deps:
	@echo "Detected OS family: $(OS_FAMILY)"
	@echo "Installing bats and shellcheck..."
	$(PKG_PREP) $(PKG_INSTALL) $(BATS_PKG) $(SC_PKG)
	@echo "✅ Dependencies installed."

# ------------------------------------------------------------------------------
lint:
	@if ! command -v shellcheck >/dev/null 2>&1; then \
		echo "shellcheck not found. Run: make deps"; \
		exit 1; \
	fi
	shellcheck -S warning $(SCRIPT_FILE)
	@echo "✅ ShellCheck passed."

# ------------------------------------------------------------------------------
test:
	@if ! command -v bats >/dev/null 2>&1; then \
		echo "bats not found. Run: make deps"; \
		exit 1; \
	fi
	bats tests/

# ------------------------------------------------------------------------------
clean:
	rm -f $(MAN_FILE).gz
	rm -rf tests/fixtures
