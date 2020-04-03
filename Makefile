SUBDIRS := bootloader \
			task

all: $(SUBDIRS)
	@mkdir -p output
	cp task/gcc/RTOSDemo.bin output/
	$(info To start run: qemu-system-arm -machine lm3s6965evb -serial stdio -kernel output/RTOSDemo.bin -s -S)
	
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
