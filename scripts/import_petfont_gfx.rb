# frozen_string_literal: true

load 'tools/reverse_tables.rb'

src = File.binread('../MS-DOS-Robots-05-22-2023/Robots/petfont.gfx')
          .unpack('C*')

dst = src.map { REVERSE_TABLE_8BIT[_1] }

File.binwrite('build/petfont.gfx', dst.pack('C*'))
