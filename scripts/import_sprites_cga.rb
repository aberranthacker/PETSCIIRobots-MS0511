# frozen_string_literal: true

src = File.binread('../MS-DOS-Robots-05-22-2023/Robots/sprites.cga')
          .unpack('C*')
dst = []
bit_number = 0
bp0_byte = 0
bp1_byte = 0

src.each do |src_byte|
  bp0_byte |= (src_byte >> 7 & 1) << bit_number
  bp1_byte |= (src_byte >> 6 & 1) << bit_number

  bit_number += 1
  bp0_byte |= (src_byte >> 5 & 1) << bit_number
  bp1_byte |= (src_byte >> 4 & 1) << bit_number

  bit_number += 1
  bp0_byte |= (src_byte >> 3 & 1) << bit_number
  bp1_byte |= (src_byte >> 2 & 1) << bit_number

  bit_number += 1
  bp0_byte |= (src_byte >> 1 & 1) << bit_number
  bp1_byte |= (src_byte >> 0 & 1) << bit_number

  next if (bit_number += 1) < 8

  dst << bp0_byte
  dst << bp1_byte

  bit_number = 0
  bp0_byte = 0
  bp1_byte = 0
end

File.binwrite('build/sprites.gfx', dst.pack('C*'))
