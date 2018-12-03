QEMU := qemu-system-x86_64
QEMU_ARGS := -enable-kvm -m 1024
QEMU_EXTRA_ARGS :=

ISO_NAME := debian-9.6.0-amd64-netinst.iso
ISO_URI := "https://ftp.acc.umu.se/debian-cd/current/amd64/iso-cd/debian-9.6.0-amd64-netinst.iso"
SHA1SUM_URI := "https://ftp.acc.umu.se/debian-cd/current/amd64/iso-cd/SHA1SUMS"

all: _base

SHA1SUM:
	@echo Downloading $@...
	@wget --no-verbose --show-progress -cO "$@" $(SHA1SUM_URI)

$(ISO_NAME): SHA1SUM
	@echo Downloading $@...
	@wget --no-verbose --show-progress -cO "$@" $(ISO_URI)
	@touch "$@" # SHA1SUM was generated later but is a dependency
	@echo Verifying checksum...
	@sha1sum -c "$<" --ignore-missing


_base: $(ISO_NAME)
	@echo Creating base image file...
	@truncate -s 20G "$@"
	@echo Starting VM...
	@${QEMU} ${QEMU_ARGS} -drive file="$@",format=raw -cdrom "$<"

%.img: _base
	@echo Copying base image...
	@cp "$<" "$@"
	@echo [!] Do not forget to edit /etc/hostname and /etc/hosts

vde/ctl:
	@echo Starting VDE switch...
	@vde_switch -Fds vde
	@echo [!] Do not forget to run \'killall vde_switch\' when you are done.

gate.vm: QEMU_EXTRA_ARGS := -netdev user,id=uplink,hostfwd=tcp:127.0.0.1:8081-:80 \
	                    -device e1000,netdev=uplink

%.vm: %.img vde/ctl
	@${QEMU} ${QEMU_ARGS} -drive file="$<",format=raw \
		-daemonize $(QEMU_EXTRA_ARGS) \
		-netdev vde,id=int1,sock=vde \
		-device e1000,netdev=int1,mac=`printf '52:54:00:EF:%02X:%02X' $$((RANDOM%256)) $$((RANDOM%256))`

clean:
	@echo Cleaning...
	@rm -rf $(DISTCLEAN_FILES) _base *.img

distclean: clean
distclean: DISTCLEAN_FILES := SHA1SUM $(ISO_NAME) vde/

.PHONY: all clean distclean
.PRECIOUS: _base %.img
