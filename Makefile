SUBDIRS := bootloader \
			task

all: $(SUBDIRS)
	@mkdir -p output
	srec_cat bootloader/app.bin -Binary -offset 0x00000000 -fill 0xff 0x00000000 0x0020000 task/app.bin -Binary -offset 0x0020000 -o output/combined.bin -Binary
	@echo "To start run: make burn"
	
$(SUBDIRS):
	@cd $@ && $(MAKE)
	@cd -

.PHONY: all $(SUBDIRS)

clean:
	@cd bootloader && $(MAKE) clean
	@cd -
	@cd task && $(MAKE) clean
	@cd -
	@rm -r output

clean_bootloader:
	@cd bootloader && $(MAKE) clean

clean_task:
	@cd task && $(MAKE) clean

burn: all
	@st-flash write output/combined.bin 0x8000000
