# frozen_string_literal: true

# @author: zayneio
# @github: https://github.com/zayneio/lut-generator
# @website: https://zayne.io

require 'rmagick'

# Generates a new Lookup Table (LUT) (saved as a '.cube' file) for a given image.
# The image path provided should be to a HALD image that you have applied your color settings to.
class LUTGenerator
  class << self
    # Given a path to an image, create a lookup table and save it
    # to the current directory as a .cube file.
    #
    # @params path [String] path to the initial image file.
    #
    # @return [Nil]
    def create_lut(path)
      Magick::ImageList.new(path).then do |image|
        File.open(output_filename(path), 'w') do |f|
          f.write(headers(steps(path), path))
          f.write(pixel_map(image).join)
        end
      end
    end

    # Set the default headers for our cube file.
    #
    # @steps [Integer]
    #
    # @return [String]
    def headers(steps, path)
      [
        "TITLE \"#{File.basename(path)}\"\n",
        "LUT_3D_SIZE #{steps**2}\n",
        "DOMAIN_MIN 0.0 0.0 0.0\n",
        "DOMAIN_MAX 1.0 1.0 1.0\n"
      ].join
    end

    # Map over each pixel and capture the RGB color info.
    #
    # @param image [Magick::Image]
    #
    # @return [Array]
    def pixel_map(image)
      array = []

      image.each_pixel do |pixel, c, r| 
        colors = [pixel.red, pixel.green, pixel.blue]
        r, g, b = rgb_map(colors)
        array.push("#{r} #{g} #{b}\n")
      end

      array
    end

    # We need to get RGB (Red, Green, Blue) in depth 8, however RMagick
    # will give us the values initially in depth 16. We can convert this by
    # dividing each value by 257.
    # 
    # Once we have converted the values to depth 8, the range for each individual colour
    # is 0-255 (2^8 = 256 possibilities). The combination range is 256*256*256.
    # We can divide each value again by 255, so that the 0-255 range can be described
    # in a 0.0-1.0 range.
    #
    # @param colors [Array] depth 16 rgb colors
    #
    # @return [Array] depth 8 rgb colors
    def rgb_map(colors)
      colors.map do |color| 
        (color / 257.0).round.then do |depth_8|
          (depth_8 / 255.0).then(&method(:format_numbers))
        end
      end
    end

    # Get the cube root of our file width.
    #
    # @param filename [String]
    #
    # @return [Integer]
    def steps(filename)
      w, _h = calculate_dimensions(filename)
      Math.exp(Math.log(w)/3.0).round
    end

    # Calculate the width & height of the base image.
    #
    # @param image [String] the image path
    #
    # @return [Array] [width, height]
    def calculate_dimensions(image)
      Magick::Image.ping(image)[0].then do |d|
        [d.columns, d.rows]
      end
    end

    # Format the filename for the cube file we will create
    # e.g. 'hald.jpg' => 'hald.cube'
    #
    # @param filename [String] the original filename
    #
    # @return [String]
    def output_filename(filename)
      File.basename(filename) 
          .split('.')
          .shift
          .then {|f| "#{f}.cube"}
    end

    # E.g. 0 => '0.000000'
    #
    # @param num [Integer]
    #
    # @return [String]
    def format_numbers(num)
      sprintf('%05.6f', num)
    end

    # @param num [Integer]
    # @param type [String]
    #
    # @return [Nil]
    def create_hald(num = 8, type = 'jpg')
      `convert hald:#{num.to_i} hald.#{img_type(type)}`
    end

    # @param type [String]
    #
    # @return [String]
    def img_type(type, default='jpg')
      %w[jpg png].include?(type) ? type : default
    end
  end
end
