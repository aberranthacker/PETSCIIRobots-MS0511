BIN_UTILS_PATH   = ~/opt/binutils-pdp11/pdp11-dec-aout/bin
BUILD_TOOLS_PATH = ./tools

AS = $(BIN_UTILS_PATH)/as
LD = $(BIN_UTILS_PATH)/ld

UKNCBTL        = ~/opt/QtUkncBtl/QtUkncBtl
AOUT2SAV       = $(BUILD_TOOLS_PATH)/aout2sav.rb
BMP_TO_GFX     = $(BUILD_TOOLS_PATH)/bmp_to_gfx
BUILD_DSK      = $(BUILD_TOOLS_PATH)/build_dsk.rb
FORMAT_LIST    = $(BUILD_TOOLS_PATH)/format_list.rb
LZSA3          = $(BUILD_TOOLS_PATH)/lzsa3
UPDATE_DISKMAP = $(BUILD_TOOLS_PATH)/update_disk_map.rb
ZX0            = $(BUILD_TOOLS_PATH)/zx0
MSDOS_VERSION_PATH = ../MS-DOS-Robots-05-22-2023/Robots
# 2.39
MAKEFLAGS += --silent --jobs
LDFLAGS += --strip-all

INCS = -I./common -I../akg_player

.SUFFIXES:
.SUFFIXES: .s .o
.PHONY: clean clean_all

MAIN_START=25344

# --just-symbols= -R include only symbols from the file
# --print-map -M
# --strip-all -s

COMMON = defs.s common/hwdefs.s common/macros.s common/rt11_macros.s common/ppu_macros.s common/keyboard_defs.s

all : pre-build dsk/robots.dsk

run : dsk/robots.dsk start_emu

start_emu :
	echo starting UKNCBTL
	$(UKNCBTL) -boot1 -disk0:dsk/robots.dsk
	echo "done"

pre-build :
	mkdir -p build
	mkdir -p dsk

clean :
	rm -f build/*.o
	rm -f build/*.out
	rm -f build/*.lst
	rm -f build/*.map
	rm -f build/*.bin
	rm -f build/*._

clean_all :
	rm -rf build/*

# robots.dsk --------------------------------------------------------------- {{{
dsk/robots.dsk : $(BUILD_DSK) \
		 $(BUILD_TOOLS_PATH)/dsk_image_constants.rb \
		 $(UPDATE_DISKMAP) \
		 dsk_flist \
		 build/bootsector.bin \
		 build/ppu_module.bin \
		 build/main.bin \
		 build/title.bin \
		 resources/level_a \
		 resources/level_b \
		 resources/level_c \
		 resources/level_d \
		 resources/level_e \
		 resources/level_f \
		 resources/level_g \
		 resources/level_h \
		 resources/level_i \
		 resources/level_j \
		 resources/level_k \
		 resources/level_l \
		 resources/level_m \
		 resources/level_n \
		 resources/level_o
	$(UPDATE_DISKMAP) dsk_flist build/bootsector.map build/bootsector.bin
	$(UPDATE_DISKMAP) dsk_flist build/main.map build/main.bin \
		-e $(MAIN_START)
	$(BUILD_DSK) dsk_flist dsk/robots.dsk
# robots.dsk --------------------------------------------------------------- }}}

# bootsector.bin ------------------------------------------------------------{{{
build/bootsector.bin : build/bootsector.o \
                       build/ppu.o \
                       build/main.o
	$(LD) $(LDFLAGS) -Map build/bootsector.map \
		-T linker_scripts/bootsector.ld \
		-R build/ppu.o
	chmod -x build/bootsector.bin

build/bootsector.o : $(COMMON) \
                     bootsector.s
	$(AS) $(INCS) -al bootsector.s -o build/bootsector.o
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

# main.bin -------------------------------------------------------------{{{
build/main.bin : build/main.out
	ruby $(AOUT2SAV) build/main.out -b -s -o build/main.bin

build/main.out : build/bootsector.o \
		 build/main.o
	$(LD) $(LDFLAGS) -Map build/main.map \
		build/main.o \
		-R build/bootsector.o \
		-o build/main.out

build/main.o : $(COMMON) \
               main.s \
               background_tasks.s \
               constants.s \
               display_weapon.s \
               draw_buffer.s \
               draw_map_window.s \
               init_game.s \
               print_info.s \
               v_blank_int_handler.s \
               vars.s \
               common/unzx0.s \
               build/intro_text.zx0 \
               build/scr_text.zx0 \
               build/scr_endgame.zx0 \
               build/c64tileset.gfx \
               resources/c64/tileset.c64
	$(AS) main.s $(INCS) -al -o build/main.o | $(FORMAT_LIST)

build/c64tileset.gfx : resources/c64/c64tileset.png scripts/png_font_to_gfx.rb
	ruby scripts/png_font_to_gfx.rb

build/intro_text.zx0 : resources/c64/intro_text
	$(ZX0) -f resources/c64/intro_text build/intro_text.zx0
build/scr_text.zx0 : resources/c64/scr_text
	$(ZX0) -f resources/c64/scr_text build/scr_text.zx0
build/scr_endgame.zx0 : resources/c64/scr_endgame
	$(ZX0) -f resources/c64/scr_endgame build/scr_endgame.zx0
# main.bin -------------------------------------------------------------}}}

#build/main_symbols.s : build/main.out scripts/main_symbols.rb
#	ruby scripts/main_symbols.rb

# title.bin -----------------------------------------------------------------{{{
build/title.bin : build/title.out
	ruby $(AOUT2SAV) build/title.out -b -s -o build/title.bin

build/title.out : build/title.o \
		  build/main.o
	$(LD) $(LDFLAGS) \
		build/title.o \
		-R build/main.o \
		-o build/title.out

build/title.o : $(COMMON) \
               title.s \
               build/title.gfx.zx0 \
               build/faces.gfx \
               resources/petfont.gfx
	$(AS) title.s $(INCS) -al -o build/title.o | $(FORMAT_LIST)

build/title.gfx.zx0 : build/title.gfx
	$(ZX0) -f build/title.gfx build/title.gfx.zx0

build/title.gfx : scripts/import_title_cga.rb
	ruby scripts/import_title_cga.rb

build/faces.gfx : resources/faces.bmp
	$(BMP_TO_GFX) resources/faces.bmp build/faces.gfx

build/petfont.gfx : scripts/import_petfont_gfx.rb
	ruby scripts/import_petfont_gfx.rb
# title.bin -----------------------------------------------------------------}}}

# common --------------------------------------------------------------------{{{
# build/unlzsa3.o : $(COMMON) common/unlzsa3.s
# 	$(AS) common/unlzsa3.s $(INCS) -o build/unlzsa3.o
#
# build/unzx0.o : $(COMMON) common/unzx0.s
# 	$(AS) common/unzx0.s $(INCS) -o build/unzx0.o
# common --------------------------------------------------------------------}}}
