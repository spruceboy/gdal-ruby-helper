#!/usr/bin/env ruby
require "rubygems"
require "pp"
require "Gdalhelper"

#basic plan - open a 256 by 256 image, write some data, set the projection and geo_trans, then quit, job done.
image_size = 256
# Open a tiff to write to, with default create options (TILED=YES, COMPRESS=LZW) to write to..
outfile = GdalFile.new(ARGV[0], "w", image_size ,image_size,3,"GTiff", String, ["COMPRESS=DEFLATE", "TILED=YES"])
0.upto(image_size-1) do |y|
  #Read a single line, line y
  bands = outfile.read_bands(0,y,image_size,1)
  y_value = ((256.0/image_size)*y).to_i
  0.upto(image_size-1) do |x|
    bands[0][x]=((256.0/image_size)*x).to_i;
    bands[1][x]= y_value
  end
  outfile.write_bands(0,y,image_size,1,bands)
end
# Set the projection
outfile.set_projection_epsg(102006)
# set the geo transform (world file)
outfile.set_geo_transform([1497254.72218513,17.6750396474176,0.0,971470.96496574,0.0,-17.6750396474176])



