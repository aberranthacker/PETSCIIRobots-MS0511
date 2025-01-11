OUTPUT_FORMAT("a.out-pdp11")
OUTPUT_ARCH(pdp11)

INPUT(build/ppu.o)
OUTPUT(build/ppu.out)

CPU_TEXT_BUFFER = TEXT_BUFFER / 2;

SECTIONS
{
    . = 0;
.text :
    {
        build/ppu.o (.text)
    }
.data :
    {
        build/ppu.o (.data)
    }
.bss :
    {
        build/ppu.o (.bss)
    }
}
