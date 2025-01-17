# frozen_string_literal: true

tileset_c64 = File.binread('resources/c64/tileset.c64')
                  .unpack('C*')
colorized_tileset = tileset_c64[0, 512]
tileset_c64 = tileset_c64[512..]

BLACK  = 0
BLUE   = 1
RED    = 2
GREEN  = 3
YELLOW = 4
GRAY   = 5
CYAN   = 6
WHITE  = 7

WALL_TOP = GRAY
WALL = CYAN
KITCHEN_SINK_TOP = GREEN
FLOOR_A = GRAY
FLOOR_B = BLUE
EARTH = WHITE
TC_TOP = YELLOW
BC_TOP = GREEN
GROUND = WHITE

colors = Array.new(256, Array.new(9, 7))

# wall: top right corner
colors[4] = [WALL_TOP, WALL_TOP, WALL_TOP,
             WALL_TOP, WALL, WALL,
             WALL_TOP, WALL, WALL]
# wall: horizontal
colors[5] = [WALL_TOP, WALL_TOP, WALL_TOP,
             WALL, WALL, WALL,
             WALL, WALL, WALL]
# wall: top right corner left
colors[6] = [WALL_TOP, WALL_TOP, WALL_TOP,
             WALL, WALL, WALL,
             WALL, WALL, WALL]
# wall: top right corner right
colors[7] = [WALL_TOP, WALL, FLOOR_A,
             WALL_TOP, WALL, WALL,
             WALL_TOP, WALL, WALL]
# vertical wall
colors[8] = [WALL_TOP, WALL, WALL,
             WALL_TOP, WALL, WALL,
             WALL_TOP, WALL, WALL]
# indoor floor
colors[9] = [GRAY, GRAY, GRAY,
             GRAY, GRAY, GRAY,
             GRAY, GRAY, GRAY]
# wall: top right corner right 2
colors[10] = [WALL_TOP, WALL, EARTH,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL]
# wall: vertical opened top
colors[11] = [WALL_TOP, WALL, WALL,
              WALL,     WALL, WALL,
              FLOOR_A,  WALL, WALL]
# wall: bottom left corner top
colors[12] = [WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL]
# wall: bottom left corner bottom
colors[13] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL, WALL, WALL,
              WALL, WALL, WALL]
# door: vertical opened bottom
colors[15] = [WALL_TOP, WALL, FLOOR_A,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL]
# wall: horizontal bottom left corner
colors[16] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL,     WALL,     WALL,
              FLOOR_A,  WALL,     WALL]
# wall: passage left
colors[17] = [WALL_TOP, WALL, FLOOR_A,
              WALL,     WALL, WALL,
              WALL,     WALL, WALL]
# wall: passage right
colors[18] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL,     WALL,     WALL,
              FLOOR_A,  WALL,     WALL]
# wall: bottom right corner
colors[19] = [WALL_TOP, WALL, WALL,
              WALL,     WALL, WALL,
              WALL,     WALL, WALL]
# flower in pot
colors[24] = [GREEN, RED,    GREEN,
              RED,   YELLOW, GRAY,
              GREEN, GRAY,   GRAY]
# door: vertical opened top
colors[27] = [WALL_TOP, WALL, WALL,
              WALL,     WALL, WALL,
              FLOOR_A,  WALL, WALL]
# chair: back top
colors[32] = [CYAN, CYAN,  GRAY,
              GRAY, GREEN, GRAY,
              GRAY, GRAY,  GRAY]
# charger top
colors[33] = [FLOOR_A, YELLOW, WALL,
              WHITE,   YELLOW, WALL,
              WHITE,   YELLOW, WALL]
# teleport pad inactive
colors[34] = [WHITE, WHITE, WHITE,
              WHITE, GRAY,  WHITE,
              WHITE, WHITE, WHITE]
# chair: back left
colors[35] = [CYAN, GRAY,  GRAY,
              CYAN, GREEN, GRAY,
              GRAY, GRAY,  GRAY]
# chair: back bottom
colors[36] = [GRAY, GRAY, GRAY,
              CYAN, CYAN, GRAY,
              GRAY, GRAY, GRAY]
# charger bottom
colors[37] = [WHITE,   YELLOW, WALL,
              FLOOR_A, YELLOW, WALL,
              FLOOR_A, WALL,   WALL]
# teleport right
colors[38] = [WHITE, FLOOR_A, FLOOR_A,
              WHITE, FLOOR_A, FLOOR_A,
              WHITE, FLOOR_A, FLOOR_A]
# chair: back right
colors[39] = [GRAY, CYAN, GRAY,
              GRAY, CYAN, GRAY,
              GRAY, GRAY, GRAY]
# dining table: top
colors[40] = [WHITE, WHITE, GRAY,
              WHITE, WHITE, FLOOR_A,
              WHITE, WHITE, FLOOR_A]
# box: closed
colors[41] = [YELLOW, YELLOW, GRAY,
              YELLOW, YELLOW, GRAY,
              GRAY, GRAY, GRAY]
# box: opened
colors[42] = [GRAY, GRAY, GRAY,
              GRAY, GRAY, GRAY,
              GRAY, GRAY, GRAY]
# desk: top
colors[43] = [GRAY, GRAY, WHITE,
              GRAY, GRAY, WHITE,
              GRAY, GRAY, GRAY]
# dining table: bottom
colors[44] = [WHITE, WHITE,   FLOOR_A,
              WHITE, WHITE,   FLOOR_A,
              GRAY,  FLOOR_A, GRAY]
# small box: closed
colors[45] = [YELLOW, GRAY, GRAY,
              GRAY,   GRAY, GRAY,
              GRAY,   GRAY, GRAY]
# small box: opened
colors[46] = [GRAY, GRAY, GRAY,
              GRAY, GRAY, GRAY,
              GRAY, GRAY, GRAY]
# desk: middle
colors[47] = [GRAY, GRAY, GRAY,
              GRAY, GRAY, GRAY,
              GRAY, GRAY, GRAY]
# kitchen sink top left
colors[48] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, KITCHEN_SINK_TOP]
# kitchen sink top middle
colors[49] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL, WALL, WALL,
              KITCHEN_SINK_TOP, KITCHEN_SINK_TOP, KITCHEN_SINK_TOP]
# kitchen sink top right
colors[50] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL, WALL, WALL,
              KITCHEN_SINK_TOP, WALL, WALL]
# desk: bottom
colors[51] = [GRAY, GRAY, GRAY,
              GRAY, GRAY, WHITE,
              WHITE, WHITE, WHITE]
# kitchen sink middle left
colors[52] = [WALL_TOP, WALL, KITCHEN_SINK_TOP,
              WALL_TOP, WALL, KITCHEN_SINK_TOP,
              WALL_TOP, WALL, KITCHEN_SINK_TOP]
# kitchen sink middle right
colors[53] = [KITCHEN_SINK_TOP, KITCHEN_SINK_TOP, KITCHEN_SINK_TOP,
              KITCHEN_SINK_TOP, WALL, WALL,
              KITCHEN_SINK_TOP, WALL, WALL]
# kitchen sink middle middle
colors[54] = [KITCHEN_SINK_TOP, WALL, FLOOR_B,
              WALL, WALL, FLOOR_B,
              FLOOR_B, FLOOR_B, FLOOR_B]
# dining table: top whith bowl
colors[55] = [WHITE, WHITE, GRAY,
              WHITE, WHITE, FLOOR_A,
              WHITE, WHITE, FLOOR_A]
# kitchen sink down left
colors[56] = [WALL_TOP, WALL, KITCHEN_SINK_TOP,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL]
# kitchen sink down left
colors[57] = [KITCHEN_SINK_TOP, WALL, FLOOR_B,
              WALL, WALL, FLOOR_B,
              FLOOR_B, FLOOR_B, FLOOR_B]
# stool
colors[58] = [FLOOR_A, FLOOR_A, FLOOR_A,
              FLOOR_A, GREEN,   GRAY,
              FLOOR_A, GRAY,    GRAY]
# dining table: bottom with bowl
colors[59] = [WHITE, WHITE,   FLOOR_A,
              WHITE, WHITE,   FLOOR_A,
              GRAY,  FLOOR_A, GRAY]
# bed left
colors[60] = [GREEN, GREEN, GREEN,
              GREEN, GREEN, GREEN,
              GREEN, GREEN, GREEN]
# bed right
colors[61] = [GREEN, GREEN, GREEN,
              GREEN, GREEN, GREEN,
              GREEN, GREEN, GREEN]
# pillar
colors[63] = [CYAN, CYAN, FLOOR_A,
              CYAN, CYAN, CYAN,
              FLOOR_A, CYAN, CYAN]
# flag
colors[66] = [CYAN,  CYAN,  CYAN,
              WHITE, WHITE, WHITE,
              WHITE, WHITE, WHITE]
# something on a pole
colors[67] = [YELLOW, YELLOW, WHITE,
              YELLOW, YELLOW, WHITE,
              WHITE,  WHITE,  WHITE]
# door: vertical closed top
colors[68] = [WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL]
# door: vertical half closed top
colors[69] = [WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL,
              WALL,     WALL, WALL]
# door: vertical half open top
colors[70] = [WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL,
              WALL,     WALL, WALL]
# club door: vertical closed top
colors[71] = [WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL]
# door: vertical closed middle
colors[72] = [WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL]
# door: vertical half closed middle
colors[73] = [WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, FLOOR_A,
              WALL_TOP, WALL, WALL]
# door: vertical half closed middle
colors[74] = [FLOOR_A, WALL, WALL,
              FLOOR_A, FLOOR_A, FLOOR_A,
              WALL_TOP, WALL, FLOOR_A]
# heart door: vertical closed top
colors[75] = [WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL]
# door: vertical closed bottom
colors[76] = [WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL]
# door: vertical half closed bottom
colors[77] = [WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL]
# door: vertical half open bottom
colors[78] = [WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL]
# star door: vertical closed top
colors[79] = [WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL,
              WALL_TOP, WALL, WALL]
# door: horizontal left
colors[80] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL,     WALL,     WALL,
              WALL,     WALL,     WALL]
# door: horizontal middle
colors[81] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL,     WALL,     WALL,
              WALL,     WALL,     WALL]
# door: horizontal right
colors[82] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL,     WALL,     WALL,
              WALL,     WALL,     WALL]
# bar counter: top open
colors[83] = [FLOOR_A, BC_TOP, GRAY,
              FLOOR_A, BC_TOP, GRAY,
              FLOOR_A, BC_TOP, GRAY]
# door: horizontal left half closed
colors[84] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL,     WALL,     WALL,
              WALL,     WALL,     WALL]
# door: half closed horizontal middle
colors[85] = [WALL, FLOOR_A, WALL_TOP,
              WALL, WALL,    WALL,
              WALL, WALL,    FLOOR_A]
# door: half closed horizontal right
colors[86] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL,     WALL,     WALL,
              WALL,     WALL,     WALL]
# bar counter: bottom
colors[87] = [FLOOR_A, BC_TOP, GRAY,
              FLOOR_A, BC_TOP, GRAY,
              FLOOR_A, GRAY,   GRAY]
# door: half open horizontal left
colors[88] = [WALL_TOP, WALL_TOP, WALL,
              WALL,     WALL,     WALL,
              WALL,     WALL,     WALL]
# door: half open horizontal middle
colors[89] = [FLOOR_A, FLOOR_A, WALL_TOP,
              WALL,    FLOOR_A, WALL,
              WALL,    FLOOR_A, FLOOR_A]
# bar counter: top
colors[90] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL,     WALL,     WALL,
              WALL,     BC_TOP,   WALL]
# door: open horizontal right
colors[91] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL,     WALL,     WALL,
              FLOOR_A,  WALL,     WALL]
# club door: horizontal right
colors[92] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL,     WALL,     WALL,
              WALL,     WALL,     WALL]
# heart door: horizontal right
colors[93] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL,     WALL,     WALL,
              WALL,     WALL,     WALL]
# star door: horizontal right
colors[94] = [WALL_TOP, WALL_TOP, WALL_TOP,
              WALL,     WALL,     WALL,
              WALL,     WALL,     WALL]
# bar counter: middle
colors[95] = [FLOOR_A, BC_TOP, GRAY,
              FLOOR_A, BC_TOP, GRAY,
              FLOOR_A, BC_TOP, GRAY]
# hoverbot a
colors[98] = [WHITE, GRAY,  GRAY,
              GRAY,  GREEN, WHITE,
              GRAY,  GRAY,  GRAY]
# hoberbot b
colors[99] = [WHITE, GRAY,   GRAY,
              GRAY,  YELLOW, WHITE,
              GRAY,  GRAY,   GRAY]
# cabinet at wall: top left
colors[112] = [WALL_TOP, WALL_TOP, WALL_TOP,
               WALL,     WALL,     WALL,
               WALL,     WALL,     WALL]
# cabinet at wall: top right
colors[113] = [WALL_TOP, WALL_TOP, WALL_TOP,
               WALL,     WALL,     WALL,
               WALL,     WALL,     WALL]
# horizontal wall with window
colors[114] = [WALL_TOP, WALL, WALL,
               WALL_TOP, WALL, WALL,
               WALL_TOP, WALL, WALL]
# cabinet at wall: bottom left
colors[116] = [FLOOR_A, WALL,    WALL,
               FLOOR_A, FLOOR_A, FLOOR_A,
               FLOOR_A, FLOOR_A, FLOOR_A]
# cabinet at wall: bottom right
colors[117] = [WALL,    FLOOR_A, FLOOR_A,
               FLOOR_A, FLOOR_A, FLOOR_A,
               FLOOR_A, FLOOR_A, FLOOR_A]
# horizontal wall with window
colors[118] = [WALL_TOP, WALL_TOP, WALL_TOP,
               WALL,     WALL,     WALL,
               WALL,     WALL,     WALL]
# pi wall: horizontal
colors[128] = [WALL_TOP, WALL_TOP, WALL_TOP,
               WALL,     WALL,     WALL,
               WALL,     WALL,     WALL]
# pi wall: vertical
colors[129] = [WALL_TOP, WALL, WALL,
               WALL_TOP, WALL, WALL,
               WALL_TOP, WALL, WALL]
# explosive canister
colors[131] = [RED,  CYAN, GRAY,
               CYAN, CYAN, GRAY,
               GRAY, GRAY, GRAY]
# pepelats ramp
colors[137] = [GRAY, GRAY, GRAY,
               GRAY, GRAY, GRAY,
               GRAY, GRAY, GRAY]
# trash compactor: open top left
colors[144] = [WALL_TOP, WALL_TOP, WALL_TOP,
               WALL,     WALL,     WALL,
               WALL,     WALL,     WALL]
# trash compactor: open top left
colors[145] = [WALL_TOP, WALL_TOP, WALL_TOP,
               WALL,     WALL,     WALL,
               WALL,     WALL,     WALL]
# trash compactor: half closed top left
colors[146] = [WALL_TOP, WALL_TOP, WALL_TOP,
               TC_TOP,   TC_TOP,   TC_TOP,
               WALL,     WALL,     WALL]
# trash compactor: half closed top left
colors[147] = [WALL_TOP, WALL_TOP, WALL_TOP,
               WALL,     WALL,     WALL,
               WALL,     WALL,     WALL]
# trash compactor glowing floor
colors[148] = [RED, YELLOW, RED,
               RED, YELLOW, RED,
               RED, YELLOW, RED]
# trash compactor: half closed bottom left
colors[150] = [RED, RED, WALL,
               RED, RED, RED,
               TC_TOP, TC_TOP, TC_TOP]
# trash compactor: half closed bottom right
colors[151] = [WALL, WALL, RED,
               RED, RED, RED,
               WALL, RED, RED]
# trash compactor: closed top left
colors[152] = [WALL_TOP, WALL_TOP, WALL_TOP,
               WALL,     WALL,     WALL,
               TC_TOP,   TC_TOP,   TC_TOP]
# trash compactor: closed top right
colors[153] = [WALL_TOP, WALL_TOP, WALL_TOP,
               WALL,     WALL,     WALL,
               WALL,     WALL,     WALL]
# trash compactor: closed bottom left
colors[156] = [WALL,   WALL,   WALL,
               TC_TOP, TC_TOP, TC_TOP,
               WALL,   WALL,   WALL]
# trash compactor: closed bottom right
colors[157] = [WALL, WALL, RED,
               WALL, WALL, RED,
               WALL, WALL, RED]
# rollerbot a
colors[164] = [GREEN, GRAY, GRAY,
               GRAY,  CYAN, BLUE,
               WHITE, BLUE, BLUE]
# rollerbot b
colors[165] = [GREEN, GRAY, WHITE,
               GRAY,  CYAN, BLUE,
               GRAY,  BLUE, BLUE]
# bathroom drawer: bottom left
colors[166] = [WALL_TOP, WALL, WALL,
               WALL_TOP,  WALL, CYAN,
               WALL_TOP,  WALL, CYAN]
# bathroom drawer: top right
colors[167] = [FLOOR_A, FLOOR_A, FLOOR_A,
               WALL,    FLOOR_A, FLOOR_A,
               WALL,    FLOOR_B, FLOOR_A]
# bathroom drawer: top left
colors[170] = [WALL_TOP, WALL, CYAN,
               WALL_TOP,  WALL, CYAN,
               WALL_TOP,  WALL, WALL]
# bathroom drawer: bottom right
colors[171] = [WALL, FLOOR_B, FLOOR_A,
               WALL,  FLOOR_B, FLOOR_A,
               WALL,  FLOOR_B, FLOOR_A]
# water
colors[204] = [BLUE, BLUE, BLUE,
               BLUE, BLUE, BLUE,
               BLUE, BLUE, BLUE]
# bridge
colors[205] = [YELLOW, WHITE, WHITE,
               YELLOW, WHITE, YELLOW,
               WHITE,  WHITE, YELLOW]
# pavement a
colors[206] = [WHITE, WHITE, GRAY,
               GRAY, WHITE,  WHITE,
               GRAY, WHITE,  WHITE]
# pavement b
colors[207] = [WHITE, WHITE, GRAY,
               WHITE, WHITE, WHITE,
               GRAY,  WHITE, WHITE]
# meadow flowers
colors[211] = [WHITE, YELLOW, GRAY,
               GREEN, GREEN,  GREEN,
               GREEN, GRAY,   WHITE]
# road
colors[214] = [GRAY, GRAY, GRAY,
               GRAY, GRAY, GRAY,
               GRAY, GRAY, GRAY]
# растение на грядке a
colors[215] = [GREEN, GREEN,  GREEN,
               GREEN, YELLOW, GREEN,
               GREEN, GREEN,  GREEN]
# fence pole: top left corner
colors[216] = [WHITE, WHITE, WHITE,
               WHITE, WHITE, GRAY,
               WHITE, GRAY,  WHITE]
# fence pole: top right corner
colors[218] = [WHITE, WHITE, WHITE,
               GRAY,  WHITE, WHITE,
               WHITE, GRAY,  WHITE]
# растение на грядке "крест"
colors[219] = [GRAY, RED,    GRAY,
               RED,  YELLOW, RED,
               GRAY, RED,    GRAY]
# fence pole: vertical
colors[220] = [WHITE,  GRAY,  GROUND,
               GROUND, WHITE, GROUND,
               GROUND, GRAY,  GROUND]
# horizontal center fence pole over water
colors[221] = [WHITE, BLUE,  BLUE,
               GRAY,  WHITE, GRAY,
               BLUE,  BLUE,  BLUE]
# tree
colors[223] = [GREEN, GREEN, GREEN,
               GREEN, RED,   GRAY,
               GREEN, GREEN, RED]
# fence pole: horizontal right
colors[225] = [WHITE, WHITE, WHITE,
               GRAY,  WHITE, WHITE,
               WHITE, WHITE, WHITE]
# fence pole: horizontal left
colors[226] = [WHITE, WHITE, WHITE,
               WHITE, WHITE, GRAY,
               WHITE, WHITE, WHITE]
# looks like road as well, wtf?
colors[227] = [CYAN, CYAN, CYAN,
               CYAN, GRAY, CYAN,
               CYAN, CYAN, CYAN]
# road, top right segment
colors[229] = [WHITE, WHITE, WHITE,
               GRAY,  WHITE, WHITE,
               GRAY,  GRAY,  WHITE]
# road, bottom left segment
colors[232] = [WHITE, GRAY,  GRAY,
               WHITE, WHITE, GRAY,
               WHITE, WHITE, WHITE]
# road: bottom right segment
colors[233] = [GRAY,  GRAY,  WHITE,
               GRAY,  WHITE, WHITE,
               WHITE, WHITE, WHITE]
# small explosion 1
colors[248] = [GRAY, GRAY, GRAY,
               GRAY, RED,  GRAY,
               GRAY, GRAY, GRAY]
# small explosion 2
colors[249] = [YELLOW, GRAY,  YELLOW,
               GRAY,   WHITE, GRAY,
               YELLOW, GRAY,  YELLOW]
# small explosion 3
colors[250] = [YELLOW, YELLOW, YELLOW,
               YELLOW, WHITE,  YELLOW,
               YELLOW, YELLOW, YELLOW]
# small explosion 4
colors[251] = [GRAY, RED,  GRAY,
               RED,  GRAY, RED,
               GRAY, RED,  GRAY]

256.times do |tile_idx|
  9.times do |subtile_idx|
    colorized_tileset << colors[tile_idx][subtile_idx]
    colorized_tileset << tileset_c64[256 * subtile_idx + tile_idx]
  end
end

File.binwrite('build/color_tileset.uknc', colorized_tileset.pack('C*'))
