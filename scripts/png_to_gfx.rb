# frozen_string_literal: true

require 'oily_png'
require_relative '../tools/reverse_tables'
require 'pry'

# Load the PNG image
image_path = 'resources/faces.png'
output_path = 'resources/faces.gfx' # Output binary file
image = ChunkyPNG::Image.from_file(image_path)

binding.pry
dst = []

image.pixels.each do |pixel|
  byte = 0

  # Get the pixel color
  # (assumes black = ChunkyPNG::Color::BLACK)
  bit = (pixel == ChunkyPNG::Color::BLACK ? 0 : 1)

  # Set the corresponding bit in the byte
  byte = (byte << 1) | bit

  dst << REVERSE_TABLE_8BIT[byte]
end

File.binwrite(output_path, dst.pack('C*'))

puts "Conversion complete! Output written to #{output_path}"
