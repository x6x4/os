SRC = src
BIN = build
LINKER_SCRIPT = $(SRC)/link.ld
BOOT_DIR = iso/boot
IMG_FILE = os.iso
EXEC_FILE = $(BOOT_DIR)/kernel.elf


.PHONY: all init builddir boot prep

all: prep boot
	
boot: 
	bochs -f boshsrc.txt -q

prep: init $(IMG_FILE)

init: builddir 

builddir: 
	mkdir -p build


#  create iso image
$(IMG_FILE):  $(EXEC_FILE)
	@echo genisoimage $^
	@genisoimage -R \
	-b boot/grub/stage2_eltorito \
	-no-emul-boot \
	-boot-load-size 4 \
	-A os \
	-input-charset utf8 \
	-quiet \
	-boot-info-table \
	-o $@ \
	iso

#  create executable file
$(EXEC_FILE): $(BIN)/loader.o
	@echo ld $^
	@ld -T $(LINKER_SCRIPT) -m elf_i386 $< -o $@ 

#  create object file
$(BIN)/loader.o: $(SRC)/loader.s 
	@echo nasm $^
	@nasm -f elf32 $(SRC)/loader.s -o $@

.PHONY: clean
clean:
	rm -r $(BIN) 
	rm $(EXEC_FILE)
	rm $(IMG_FILE)
