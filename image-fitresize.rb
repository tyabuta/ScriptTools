#!/usr/bin/env ruby
# encoding: utf-8


require 'optparse'

# apt-get install imagemagick libmagickwand-dev
# gem install rmagick
require 'rubygems'
require 'RMagick'


#
# アスペクト比を維持したまま指定サイズに収まるようリサイズ処理を行う。
#
def resize_to_fit(image_path, output_path, target_width, target_height)
    image = Magick::ImageList.new(image_path)
    image.resize_to_fit!(target_width, target_height)
    image.write(output_path)
end


# -------------------------------------------------------------------
# main
# -------------------------------------------------------------------

options = {
    filename: "",
    output:   "",
    width:    1,
    height:   1,
}

# コマンドラインの解析
OptionParser.new do |parser|
    parser.on("--file [FILENAME]", "image source")          { |v| options[:filename] = v }
    parser.on("--output [OUTPUT]", "output image file name"){ |v| options[:output]   = v }
    parser.on("--width  [WIDTH]",  "width")  { |v| options[:width]  = v.to_i }
    parser.on("--height [HEIGHT]", "height") { |v| options[:height] = v.to_i }
    parser.parse!(ARGV)
end

print "options = "
p options


resize_to_fit(options[:filename], options[:output], options[:width], options[:height])
exit 0

