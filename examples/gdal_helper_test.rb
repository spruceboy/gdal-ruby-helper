#!/usr/bin/env ruby
require "pp"
require "ruby_gdal_helper"

## Open input file
infile = Gdal_File.new(ARGV[0])
puts ("#{ARGV[0]} -> #{infile}")
# Read the upper left hand quarter
bands =  infile.read_bands(0,0,infile.xsize/4,infile.ysize/4)
# Open a file to write to..
outfile = Gdal_File.new(ARGV[1], "w", infile.xsize/4 , infile.ysize/4,infile.number_of_bands,"GTiff", infile.data_type )
# write the upper left hand quarter..
outfile.write_bands(0,0,infile.xsize/4,infile.ysize/4,bands)
# Set the projection
outfile.set_projection_epsg(102006)



