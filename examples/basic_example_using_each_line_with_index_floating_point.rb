#!/usr/bin/env ruby
require "rubygems"
require "pp"
require "gdal_helper"

#basic plan - make a 256 by 256 geotif with floating point values
# Open a tiff to write to, with default create options (TILED=YES, COMPRESS=LZW) to write to..
if (ARGV.length != 1)
  puts("This wiget provides a very basic example of making a floating point geotiff using the ruby binding helpers")
  puts("Usage: ./basic_example_using_each_line_with_index_floating_point.rb (outfile)")
  exit
end

xsize=256
ysize=256

outfile = GdalFile.new(ARGV[0], "w", xsize,ysize,1,"GTiff", Float, ["COMPRESS=DEFLATE", "TILED=YES"])
y = 0
outfile.each_line_with_index do |y_index,data|
  data.each do |band|
    band.each_index do |x_index|
      x = (x_index.to_f / xsize) -0.5
      y = (y_index.to_f / ysize) -0.5
      band[x_index]= Math.atan2(x,y)
    end
  end
  outfile.write_bands(0,y_index,xsize,1,data)
end



