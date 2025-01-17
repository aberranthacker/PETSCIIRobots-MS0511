# frozen_string_literal: true

bw_scr_text = File.binread('resources/c64/scr_text').bytes
color_scr_text = []

bw_scr_text.each do |byte|
  color_scr_text << 7
  color_scr_text << byte
end

offset = 21 * 40 * 2

color_scr_text[offset] = 1
28.times { |i| color_scr_text[offset + (12 + i) * 2] = 1 }

offset = 24 * 40 * 2
color_scr_text[offset + 34 * 2] = 2
color_scr_text[offset + 35 * 2] = 2
color_scr_text[offset + 36 * 2] = 4
color_scr_text[offset + 37 * 2] = 4
color_scr_text[offset + 38 * 2] = 3
color_scr_text[offset + 39 * 2] = 3

offset = 33 * 2
25.times { |i| color_scr_text[offset + i * 40 * 2] = 1 }

offset = 17 * 40 * 2 + 34 * 2
8.times { |i| color_scr_text[offset + i * 2] = 1 }
offset = 13 * 40 * 2 + 34 * 2
8.times { |i| color_scr_text[offset + i * 2] = 1 }
offset = 6 * 40 * 2 + 34 * 2
8.times { |i| color_scr_text[offset + i * 2] = 1 }

File.binwrite('build/color_scr_text', color_scr_text.pack('C*'))
