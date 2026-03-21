PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
SCRIPT   = memcache-top

.PHONY: install uninstall check help

help:
	@echo ""
	@echo "  memcache-top Makefile"
	@echo ""
	@echo "  Usage:"
	@echo "    make install           Install to $(BINDIR)"
	@echo "    make install PREFIX=/opt  Install to /opt/bin"
	@echo "    make uninstall         Remove from $(BINDIR)"
	@echo "    make check             Verify dependencies"
	@echo ""

install: check
	@mkdir -p $(BINDIR)
	@cp $(SCRIPT) $(BINDIR)/$(SCRIPT)
	@chmod +x $(BINDIR)/$(SCRIPT)
	@echo "[+] Installed $(SCRIPT) to $(BINDIR)/$(SCRIPT)"
	@echo "    Run 'memcache-top --help' to get started."

uninstall:
	@rm -f $(BINDIR)/$(SCRIPT)
	@echo "[+] Removed $(SCRIPT) from $(BINDIR)"

check:
	@echo "Checking dependencies..."
	@perl -v > /dev/null 2>&1 || (echo "[x] perl is required" && exit 1)
	@perl -MIO::Socket -e 1 2>/dev/null || (echo "[x] IO::Socket missing" && exit 1)
	@perl -MTime::HiRes -e 1 2>/dev/null || (echo "[x] Time::HiRes missing" && exit 1)
	@echo "[+] All required dependencies OK"
