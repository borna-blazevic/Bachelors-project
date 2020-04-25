SUBDIRS := bootloader \
			task

all: $(SUBDIRS)
	@mkdir -p output
	srec_cat bootloader/gcc/RTOSDemoBootloader.bin -Binary -offset 0x00000000 -fill 0xff 0x00000000 0x00004000 task/gcc/RTOSDemo.bin -Binary -offset 0x00004000 -o output/combined.bin -Binary
	@echo "To start run: qemu-system-arm -machine lm3s6965evb -serial stdio -kernel output/combined.bin -s -S"
	
$(SUBDIRS):
	@cd $@ && $(MAKE)
	@cd -

.PHONY: all $(SUBDIRS)

clean:
	@cd bootloader && $(MAKE) clean
	@cd -
	@cd task && $(MAKE) clean

clean_bootloader:
	@cd bootloader && $(MAKE) clean

clean_task:
	@cd task && $(MAKE) clean
