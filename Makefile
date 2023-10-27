prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox

install: build
	install -d "$(bindir)"
	install ".build/release/localdic" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/localdic"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
