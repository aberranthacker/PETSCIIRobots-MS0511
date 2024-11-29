# frozen_string_literal: true

require 'oily_png'
require 'pry'

SWAP_TABLE = [0, 2, 1, 3].freeze
PATH = '../MS-DOS-Robots-05-22-2023/Robots/'
FILES_PARAMS = [
  { filename: 'faces', width: 24, height: 78 }, # 24x26x3
  # { filename: 'gameover', width: 320, height: 200 },
  { filename: 'health', width: 48, height: 306 },
  { filename: 'items', width: 48, height: 126 },
  { filename: 'keys', width: 16, height: 42 },
  { filename: 'sprites', width: 24, height: 1992 },
  { filename: 'tiles', width: 24, height: 6072 },
].freeze

PALETTE = [
  ChunkyPNG::Color::BLACK,
  ChunkyPNG::Color.rgb(0, 127, 127),
  ChunkyPNG::Color.rgb(0, 255, 255),
  ChunkyPNG::Color::WHITE,
].freeze

FILES_PARAMS.each do |file_params|
  src = File.binread("#{PATH}#{file_params[:filename]}.cga")
            .unpack('C*')
  height = file_params[:height]
  width = file_params[:width]

  image = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)

  # Process each pixel
  byte_index = 0
  bit_index = 0

  height.times do |y|
    width.times do |x|
      # Read 2 bits for the current pixel
      byte = src[byte_index] || 0
      color_index = (byte >> (6 - bit_index)) & 0x03 # Extract 2 bits
      color_index = SWAP_TABLE[color_index]

      # Set the pixel color using the palette
      image[x, y] = PALETTE[color_index]

      # Move to the next 2 bits
      bit_index += 2
      if bit_index >= 8
        bit_index = 0
        byte_index += 1
      end
    end
  end

  image.save("resources/#{file_params[:filename]}.png")
end
