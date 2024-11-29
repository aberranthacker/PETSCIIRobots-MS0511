BIN_UTILS_PATH   = ~/opt/binutils-pdp11/pdp11-dec-aout/bin
BUILD_TOOLS_PATH = ./tools

AS = $(BIN_UTILS_PATH)/as
LD = $(BIN_UTILS_PATH)/ld

AOUT2SAV       = $(BUILD_TOOLS_PATH)/aout2sav.rb
BMP_TO_RAW     = $(BUILD_TOOLS_PATH)/bmp_to_raw
BUILD_DSK      = $(BUILD_TOOLS_PATH)/build_dsk.rb
FORMAT_LIST    = $(BUILD_TOOLS_PATH)/format_list.rb
LZSA3          = $(BUILD_TOOLS_PATH)/lzsa3
UPDATE_DISKMAP = $(BUILD_TOOLS_PATH)/update_disk_map.rb
ZX0            = $(BUILD_TOOLS_PATH)/zx0
# 2.38
MAKEFLAGS += --silent --jobs
LDFLAGS += --strip-all

INCS = -I./common -I../akg_player

.SUFFIXES:
.SUFFIXES: .s .o
.PHONY: clean clean_all

# --just-symbols= -R include only symbols from the file
# --print-map -M
# --strip-all -s

COMMON = defs.s common/hwdefs.s common/macros.s common/rt11_macros.s common/ppu_macros.s

all : pre-build dsk/robots.dsk

pre-build :
	mkdir -p build
	mkdir -p dsk

clean :
	rm -rf build/*

# robots.dsk --------------------------------------------------------------- {{{
dsk/robots.dsk : $(BUILD_DSK) \
		 $(BUILD_TOOLS_PATH)/dsk_image_constants.rb \
		 $(UPDATE_DISKMAP) \
		 dsk_flist \
		 build/bootsector.bin \
		 build/ppu_module.bin \
		 build/bootstrap.bin
	$(UPDATE_DISKMAP) dsk_flist build/bootsector.map.txt build/bootsector.bin
	$(BUILD_DSK) dsk_flist dsk/robots.dsk
# robots.dsk --------------------------------------------------------------- }}}

# bootsector.bin ------------------------------------------------------------{{{
build/bootsector.bin : build/bootsector.o \
                       build/ppu.o \
                       build/bootstrap.o
	$(LD) $(LDFLAGS) -M \
		-T linker_scripts/bootsector.ld \
		-R build/ppu.o > build/bootsector.map.txt
	chmod -x build/bootsector.bin

build/bootsector.o : $(COMMON) \
                     bootsector.s
	$(AS) $(INCS) -al bootsector.s -o build/bootsector.o | $(FORMAT_LIST)
# bootsector.bin ------------------------------------------------------------}}}

# ppu_module.bin ------------------------------------------------------------{{{
build/ppu_module.bin : build/ppu.o
	$(LD) $(LDFLAGS) -T linker_scripts/ppu.ld -R build/title.o
	ruby $(AOUT2SAV) build/ppu.out -b -s -o build/ppu_module.bin
build/ppu.o : $(COMMON) \
              ppu.s \
              ppu/sltab_init.s \
              ppu/channel_0_in_int_handler.s \
              ppu/channel_1_in_int_handler.s \
              ppu/vblank_int_handler.s \
              ppu/keyboard_int_handler.s \
              ppu/puts.s \
              audio.s \
              build/petfont.gfx
	$(AS) ppu.s $(INCS) -al -o build/ppu.o | $(FORMAT_LIST)
# ppu_module.bin ------------------------------------------------------------}}}

# bootstrap.bin -------------------------------------------------------------{{{
build/bootstrap.bin : build/bootstrap.o build/unlzsa3.o build/unzx0.o
	$(LD) $(LDFLAGS) build/bootstrap.o build/unlzsa3.o build/unzx0.o -o build/bootstrap.out
	ruby $(AOUT2SAV) build/bootstrap.out -b -s -o build/bootstrap.bin
build/bootstrap.o : $(COMMON) \
               bootstrap.s \
               build/title.gfx.zx0 \
               build/tiles.gfx \
               build/faces.gfx \
               build/petfont.gfx \
               display_petscii_gfx.s
	$(AS) bootstrap.s $(INCS) -al -o build/bootstrap.o | $(FORMAT_LIST)

build/title.gfx.zx0 : build/title.gfx
	$(ZX0) -f build/title.gfx build/title.gfx.zx0
build/title.gfx.lzsa3 : build/title.gfx
	$(LZSA3) build/title.gfx build/title.gfx.lzsa3
build/title.gfx : scripts/import_title_cga.rb
	ruby scripts/import_title_cga.rb

build/tiles.gfx : scripts/import_tiles_cga.rb
	ruby scripts/import_tiles_cga.rb

build/faces.gfx : scripts/import_faces_cga.rb
	ruby scripts/import_faces_cga.rb

build/petfont.gfx : scripts/import_petfont_gfx.rb
	ruby scripts/import_petfont_gfx.rb
# bootstrap.bin -------------------------------------------------------------}}}

# common --------------------------------------------------------------------{{{
build/unlzsa3.o : $(COMMON) common/unlzsa3.s
	$(AS) common/unlzsa3.s $(INCS) -o build/unlzsa3.o

build/unzx0.o : $(COMMON) common/unzx0.s
	$(AS) common/unzx0.s $(INCS) -o build/unzx0.o
# common --------------------------------------------------------------------}}}
