#!/usr/bin/env ruby
require "rubygems"
require "pp"
require "gdal_helper"

#basic plan - open image,dim image by 25%, set the projection and geo_trans, then quit, job done.
# Open a tiff to write to, with default create options (TILED=YES, COMPRESS=LZW) to write to..
if (ARGV.length != 2)
  puts("Usage: ./basic_example_using_each_line.rb (infile) (outfile)")
  return -1
end

infile = GdalFile.new(ARGV[0])
outfile = GdalFile.new(ARGV[1], "w", infile.xsize,infile.ysize,infile.number_of_bands,"GTiff", infile.data_type, ["COMPRESS=DEFLATE", "TILED=YES"])
y = 0
infile.each_line do |data|
  data.each do |band|
    band.each_index do |x_index|
      band[x_index] = band[x_index] - band[x_index]/4
    end
  end
  outfile.write_bands(0,y,infile.xsize,1,data)
  y += 1
end
# Set the projection
outfile.set_projection(infile.get_projection)
# set the geo transform (world file)
outfile.set_geo_transform(infile.get_geo_transform)



