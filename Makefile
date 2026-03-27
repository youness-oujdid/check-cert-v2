# ==============================================================================
# check-cert Makefile
# ==============================================================================

SCRIPT_NAME  = check-cert
SCRIPT_FILE  = check_cert_key_match
MAN_FILE     = check-cert.1
INSTALL_DIR  = /usr/local/bin
MAN_DIR      = /usr/share/man/man1
VERSION      = $(shell grep '^VERSION=' $(SCRIPT_FILE) | cut -d'"' -f2)

.PHONY: all install uninstall clean test lint release

all:
	@echo "check-cert v$(VERSION)"
	@echo ""
	@echo "Available targets:"
	@echo "  install    — Install script and man page"
	@echo "  uninstall  — Remove installed files"
	@echo "  test       — Run bats test suite"
	@echo "  lint       — Run shellcheck"
	@echo "  clean      — Remove generated files"

install: $(SCRIPT_FILE) $(MAN_FILE)
	@echo "Installing check-cert v$(VERSION)..."
	sudo cp $(SCRIPT_FILE) $(INSTALL_DIR)/$(SCRIPT_NAME)
	sudo chmod +x $(INSTALL_DIR)/$(SCRIPT_NAME)
	@echo "Installing man page..."
	gzip -kf $(MAN_FILE)
	sudo cp $(MAN_FILE).gz $(MAN_DIR)/$(MAN_FILE).gz
	sudo mandb -q
	@echo "✅ Installed! Run: check-cert --help"

uninstall:
	@echo "Removing check-cert..."
	sudo rm -f $(INSTALL_DIR)/$(SCRIPT_NAME)
	sudo rm -f $(MAN_DIR)/$(MAN_FILE).gz
	sudo mandb -q
	@echo "✅ Uninstalled."

lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "Install shellcheck first: sudo apt install shellcheck"; exit 1; }
	shellcheck -S warning $(SCRIPT_FILE)
	@echo "✅ ShellCheck passed."

test:
	@command -v bats >/dev/null 2>&1 || { echo "Install bats first: sudo apt install bats"; exit 1; }
	bats tests/

clean:
	rm -f $(MAN_FILE).gz
	rm -rf tests/fixtures
