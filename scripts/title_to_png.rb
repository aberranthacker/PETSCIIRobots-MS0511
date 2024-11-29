# frozen_string_literal: true

require 'oily_png'

# Define the image dimensions
width = 320
height = 200

palette = [
  ChunkyPNG::Color::BLACK,
  ChunkyPNG::Color.rgb(0, 127, 127),
  ChunkyPNG::Color.rgb(0, 255, 255),
  ChunkyPNG::Color::WHITE,
]

src = File.binread('../MS-DOS-Robots-05-22-2023/Robots/title.cga')
          .unpack('C*')
even_lines = src[0...8000]
odd_lines = src[8_192...16_192]
puts even_lines.size
puts odd_lines.size
src = []

0.upto(99) do |i|
  src += even_lines[i * 80..(i * 80 + 79)]
  src += odd_lines[i * 80..(i * 80 + 79)]
end

SWAP_TABLE = [0, 2, 1, 3].freeze

# Initialize a new ChunkyPNG image
image = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)

# Process each pixel
byte_index = 0
bit_index = 0

height.times do |y|
  width.times do |x|
    # Read 2 bits for the current pixel
    byte = src[byte_index]
    color_index = (byte >> (6 - bit_index)) & 0x03 # Extract 2 bits
    color_index = SWAP_TABLE[color_index]

    # Set the pixel color using the palette
    image[x, y] = palette[color_index]

    # Move to the next 2 bits
    bit_index += 2
    if bit_index >= 8
      bit_index = 0
      byte_index += 1
    end
  end
end

# Save the image as a PNG file
image.save('output.png')
