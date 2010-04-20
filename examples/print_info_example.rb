#!/usr/bin/env ruby
# Basic example - opens the files in argv and prints some info on them..
require "pp"
require "ruby_gdal_helper"

ARGV.each do |item|
  gdal_file = Gdal_File.new(item)  #open the file..
  size = gdal_file.size()  #get the size hash..
  puts("#{item}: #{size["x"]}x#{size["y"]}")
  puts("#{item}: #{size["bands"]} bands of type #{size["data_type"]}")
  puts("#{item}: projection -> '#{gdal_file.get_projection}'")
  puts("#{item}: geo_transform -> [#{gdal_file.get_geo_transform.join(",")}]")
end

