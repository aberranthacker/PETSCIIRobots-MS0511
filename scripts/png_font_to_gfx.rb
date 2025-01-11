# frozen_string_literal: true

require 'oily_png'
require_relative '../tools/reverse_tables'

# Constants
TILE_WIDTH = 8
TILE_HEIGHT = 8

# Load the PNG image
image_path = 'resources/c64/c64tileset.png'
output_path = 'build/c64tileset.gfx' # Output binary file
image = ChunkyPNG::Image.from_file(image_path)

dst = []
# Ensure the image dimensions match the expected size
if (image.width % 8).positive? || (image.height % 8).positive?
  raise 'Image width and height must be dividable by 8'
end

# Process each tile row by row, column by column
(image.height / TILE_HEIGHT).times do |tile_row|
  (image.width / TILE_WIDTH).times do |tile_col|
    # Extract each tile
    TILE_HEIGHT.times do |tile_y|
      byte = 0
      TILE_WIDTH.times do |tile_x|
        # Calculate the pixel's absolute position in the image
        x = tile_col * TILE_WIDTH + tile_x
        y = tile_row * TILE_HEIGHT + tile_y

        # Get the pixel color
        # (assumes black = ChunkyPNG::Color::BLACK)
        pixel = image[x, y]
        bit = (pixel == ChunkyPNG::Color::BLACK ? 0 : 1)

        # Set the corresponding bit in the byte
        byte = (byte << 1) | bit
      end

      dst << REVERSE_TABLE_8BIT[byte]
      dst << REVERSE_TABLE_8BIT[byte]
    end
  end
end

File.binwrite(output_path, dst.pack('C*'))

puts "Conversion complete! Output written to #{output_path}"
