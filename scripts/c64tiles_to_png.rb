# frozen_string_literal: true

require 'oily_png'

tileset_c64 = File.binread('resources/c64/tileset.c64').bytes[512..]
composite_tiles = []

256.times do |tile_idx|
  composite_tile = []
  9.times do |subtile_idx|
    composite_tile << tileset_c64[256 * subtile_idx + tile_idx]
  end
  composite_tiles << composite_tile
end

tile_data = []
File.binread('build/c64tileset.gfx').bytes.each_with_index do |byte, idx|
  next if idx.odd?

  tile_data << byte
end

# Функция для получения 8x8 тайла из массива тайлов
def extract_tile(tile_data, tile_index)
  tile_size = 8
  tile = Array.new(tile_size) { Array.new(tile_size, 0) }
  base_index = tile_index * tile_size

  (0...tile_size).each do |y|
    byte = tile_data[base_index + y]
    (0...tile_size).each do |x|
      tile[y][x] = (byte >> x) & 1
    end
  end

  tile
end

# Функция для создания составного тайла размером 24x24 из массива индексов
def create_composite_tile(tile_data, composite_tile_indices)
  composite_tile_size = 24
  composite_tile = Array.new(composite_tile_size) { Array.new(composite_tile_size, 0) }

  (0...3).each do |ty|
    (0...3).each do |tx|
      tile_index = composite_tile_indices[ty * 3 + tx]
      tile = extract_tile(tile_data, tile_index)

      (0...8).each do |y|
        (0...8).each do |x|
          composite_tile[ty * 8 + y][tx * 8 + x] = tile[y][x]
        end
      end
    end
  end

  composite_tile
end

# Функция для создания изображения PNG из массива составных тайлов
def create_image(tile_data, composite_tiles)
  num_tiles = Math.sqrt(composite_tiles.size).to_i
  image_size = num_tiles * 24

  png = ChunkyPNG::Image.new(image_size, image_size, ChunkyPNG::Color::WHITE)

  composite_tiles.each_with_index do |composite_tile_indices, index|
    composite_tile = create_composite_tile(tile_data, composite_tile_indices)

    x_offset = (index % num_tiles) * 24
    y_offset = (index / num_tiles) * 24

    (0...24).each do |y|
      (0...24).each do |x|
        color = composite_tile[y][x] == 1 ? ChunkyPNG::Color::WHITE : ChunkyPNG::Color::BLACK
        png[x_offset + x, y_offset + y] = color
      end
    end
  end

  png
end

# Создаем PNG-изображение
image = create_image(tile_data, composite_tiles)

# Сохраняем в файл
image.save('composite_tiles.png')
