#!/usr/bin/env ruby
# A simple wrapper class for gdal - the goal is to provide a very simple and easy interface to gdal in ruby.  
# Ruby's gdal bindings, and ruby's ogr bindings are required.
# blame for this work goes to jay@spruceboy.net
# Feel free to fork/revamp/whatever - credit would be nice, but not required.
# I am hoping some more qualified folks will take this on and make it gleam with super goodness - Have at it folks!
require "gdal/gdal"
require "gdal/gdalconst"
require 'gdal/osr'


###
# Helper class for gdal.

# class with constants and bits that will be used by all gdal-helper classes
class GdalStuff
  # Does type mappings from gdal to ruby - pretty basic, and needs to be expanded so other types can be done, like for example
  # 32 bit integer types, 16 bit types, double floating bit types, unsigned int types, etc..
  def data_type_from_gdal(data_type)
    case (data_type)
      when Gdal::Gdalconst::GDT_UNKNOWN; return null
      when Gdal::Gdalconst::GDT_BYTE; return String
      when Gdal::Gdalconst::GDT_UINT16 ; return Integer
      when Gdal::Gdalconst::GDT_INT16; return Integer
      when Gdal::Gdalconst::GDT_UINT32; return Integer
      when Gdal::Gdalconst::GDT_INT32; return Integer
      when Gdal::Gdalconst::GDT_FLOAT32; return Float
      when Gdal::Gdalconst::GDT_FLOAT64; return Float
      when Gdal::Gdalconst::GDT_CINT16; return Integer
      when Gdal::Gdalconst::GDT_CINT32; return Float
      when Gdal::Gdalconst::GDT_CFLOAT32; return Float
      when Gdal::Gdalconst::GDT_CFLOAT64; return Float
      else raise ArgumentError("Unknown data type.. not sure what to do here folks", caller)
    end
  end
  
  # Does type mappings from ruby to gdal - pretty basic, and needs to be expanded so other types can be done, like for example
  # 32 bit integer types, 16 bit types, double floating bit types, unsigned int types, etc..
  def data_type_to_gdal ( data_type )
    #puts("DEBUG: data_type_to_gdal(#{data_type})")
    # Does not work, something is wrong with my understanding of the case statement and class compares..
    #case (data_type)
    #  when String; return Gdal::Gdalconst::GDT_BYTE
    #  when Integer; return Gdal::Gdalconst::GDT_INT16
    #  when Float; return Gdal::Gdalconst::GDT_FLOAT32
    #end
    return Gdal::Gdalconst::GDT_BYTE if (data_type == String )
    return Gdal::Gdalconst::GDT_INT16 if (data_type == Integer )
    return Gdal::Gdalconst::GDT_FLOAT32 if (data_type == Float )
    raise ArgumentError, "#{data_type} is not a valid (String|Integer|Float) data type.. not sure what to do here folks", caller
  end
  
end

##
# Class wrapping up a gdal band. 
class GdalBand < GdalStuff
  
  def initialize( band)
    @band = band
  end
  #Reads data
  def read(start_x, start_y, width_x, width_y)
    return unpack(width_y*width_x,  @band.read_raster(start_x,start_y,width_x,width_y))
  end
  
  #Writes data
  def write(start_x, start_y, width_x, width_y, data)
    return @band.write_raster(start_x,start_y,width_x,width_y, pack(data))
  end
  
  #returns the datatype
  def data_type()
    data_type_from_gdal(@band.DataType)
  end
  
  #returns the datatype as a string in a gdal like manner
  def data_type_pretty()
    type_string = case(@band.DataType)
      when Gdal::Gdalconst::GDT_UNKNOWN; 'GDT_UNKNOWN'
      when Gdal::Gdalconst::GDT_BYTE; 'GDT_BYTE'
      when Gdal::Gdalconst::GDT_UINT16;'GDT_UINT16'
      when Gdal::Gdalconst::GDT_INT16;'GDT_INT16'
      when Gdal::Gdalconst::GDT_UINT32; 'GDT_UINT32'
      when Gdal::Gdalconst::GDT_INT32; 'GDT_INT32'
      when Gdal::Gdalconst::GDT_FLOAT32; 'IDT_FLOAT32'
      when Gdal::Gdalconst::GDT_FLOAT64; 'GDT_FLOAT64'
      when Gdal::Gdalconst::GDT_CINT16; 'GDT_CINT16'   
      when Gdal::Gdalconst::GDT_CINT32; 'GDT_CINT32'  
      when Gdal::Gdalconst::GDT_CFLOAT32; 'GDT_CFLOAT32' 
      when Gdal::Gdalconst::GDT_CFLOAT64; 'GDT_CFLOAT64'
      else raise ArgumentError("Unknown data type.. not sure what to do here folks", caller)
    end
    type_string
  end
  
  #converts to a string for display/print/other .to_s action
  def to_s
    "#{data_type_pretty}"
  end
  
  private
  
   # string.pack notes - for refrence for the function below.
   #  Format | Returns | Function
   #-------+---------+-----------------------------------------
   #  A    | String  | with trailing nulls and spaces removed
   #-------+---------+-----------------------------------------
   #  a    | String  | string
   #-------+---------+-----------------------------------------
   #  B    | String  | extract bits from each character (msb first)
   #-------+---------+-----------------------------------------
   #  b    | String  | extract bits from each character (lsb first)
   #-------+---------+-----------------------------------------
   #  C    | Fixnum  | extract a character as an unsigned integer
   #-------+---------+-----------------------------------------
   #  c    | Fixnum  | extract a character as an integer
   #-------+---------+-----------------------------------------
   #  d,D  | Float   | treat sizeof(double) characters as
   #       |         | a native double
   #-------+---------+-----------------------------------------
   #  E    | Float   | treat sizeof(double) characters as
   #       |         | a double in little-endian byte order
   #-------+---------+-----------------------------------------
   #  e    | Float   | treat sizeof(float) characters as
   #       |         | a float in little-endian byte order
   #-------+---------+-----------------------------------------
   #  f,F  | Float   | treat sizeof(float) characters as
   #       |         | a native float
   #-------+---------+-----------------------------------------
   #  G    | Float   | treat sizeof(double) characters as
   #       |         | a double in network byte order
   #-------+---------+-----------------------------------------
   #  g    | Float   | treat sizeof(float) characters as a
   #       |         | float in network byte order
   #-------+---------+-----------------------------------------
   #  H    | String  | extract hex nibbles from each character
   #       |         | (most significant first)
   #-------+---------+-----------------------------------------
   #  h    | String  | extract hex nibbles from each character
   #       |         | (least significant first)
   #-------+---------+-----------------------------------------
   #  I    | Integer | treat sizeof(int) (modified by _)
   #       |         | successive characters as an unsigned
   #       |         | native integer
   #-------+---------+-----------------------------------------
   #  i    | Integer | treat sizeof(int) (modified by _)
   #       |         | successive characters as a signed
   #       |         | native integer
   #-------+---------+-----------------------------------------
   #  L    | Integer | treat four (modified by _) successive
   #       |         | characters as an unsigned native
   #       |         | long integer
   #-------+---------+-----------------------------------------
   #  l    | Integer | treat four (modified by _) successive
   #       |         | characters as a signed native
   #       |         | long integer
   #-------+---------+-----------------------------------------
   #  M    | String  | quoted-printable
   #-------+---------+-----------------------------------------
   #  m    | String  | base64-encoded
   #-------+---------+-----------------------------------------
   #  N    | Integer | treat four characters as an unsigned
   #       |         | long in network byte order
   #-------+---------+-----------------------------------------
   #  n    | Fixnum  | treat two characters as an unsigned
   #       |         | short in network byte order
   #-------+---------+-----------------------------------------
   #  P    | String  | treat sizeof(char *) characters as a
   #       |         | pointer, and  return \emph{len} characters
   #       |         | from the referenced location
   #-------+---------+-----------------------------------------
   #  p    | String  | treat sizeof(char *) characters as a
   #       |         | pointer to a  null-terminated string
   #-------+---------+-----------------------------------------
   #  Q    | Integer | treat 8 characters as an unsigned
   #       |         | quad word (64 bits)
   #-------+---------+-----------------------------------------
   #  q    | Integer | treat 8 characters as a signed
   #       |         | quad word (64 bits)
   #-------+---------+-----------------------------------------
   #  S    | Fixnum  | treat two (different if _ used)
   #       |         | successive characters as an unsigned
   #       |         | short in native byte order
   #-------+---------+-----------------------------------------
   #  s    | Fixnum  | Treat two (different if _ used)
   #       |         | successive characters as a signed short
   #       |         | in native byte order
   #-------+---------+-----------------------------------------
   #  U    | Integer | UTF-8 characters as unsigned integers
   #-------+---------+-----------------------------------------
   #  u    | String  | UU-encoded
   #-------+---------+-----------------------------------------
   #  V    | Fixnum  | treat four characters as an unsigned
   #       |         | long in little-endian byte order
   #-------+---------+-----------------------------------------
   #  v    | Fixnum  | treat two characters as an unsigned
   #       |         | short in little-endian byte order
   #-------+---------+-----------------------------------------
   #  w    | Integer | BER-compressed integer (see Array.pack)
   #-------+---------+-----------------------------------------
   #  X    | ---     | skip backward one character
   #-------+---------+-----------------------------------------
   #  x    | ---     | skip forward one character
   #-------+---------+-----------------------------------------
   #  Z    | String  | with trailing nulls removed
   #       |         | upto first null with *
   #-------+---------+-----------------------------------------
   #  @    | ---     | skip to the offset given by the
   #       |         | length argument
   #-------+---------+-----------------------------------------
  #unpacks the data
  def unpack ( items, data)
    pack_template = case (@band.DataType)
      when Gdal::Gdalconst::GDT_UNKNOWN;raise ArgumentError, "GDT_UNKNOWN has no storage template.. not sure what to do here folks", caller
      when Gdal::Gdalconst::GDT_BYTE; 'C'
      when Gdal::Gdalconst::GDT_UINT16;'S'
      when Gdal::Gdalconst::GDT_INT16;'s'
      when Gdal::Gdalconst::GDT_UINT32; 'I'
      when Gdal::Gdalconst::GDT_INT32; 'i'
      when Gdal::Gdalconst::GDT_FLOAT32; 'f'
      when Gdal::Gdalconst::GDT_FLOAT64; 'D'
      when Gdal::Gdalconst::GDT_CINT16; ''    #What are these?
      when Gdal::Gdalconst::GDT_CINT32; ''    #What are these?
      when Gdal::Gdalconst::GDT_CFLOAT32; ''  #What are these?
      when Gdal::Gdalconst::GDT_CFLOAT64; '' #What are these?
      else raise ArgumentError("Unknown data type.. not sure what to do here folks", caller)
    end
    return data.unpack(pack_template*data.length)
  end
  
 #Notes for pack..
 # #Directives for pack.
 #
 #Directive    Meaning
 #---------------------------------------------------------------
 #    @     |  Moves to absolute position
 #    A     |  ASCII string (space padded, count is width)
 #    a     |  ASCII string (null padded, count is width)
 #    B     |  Bit string (descending bit order)
 #    b     |  Bit string (ascending bit order)
 #    C     |  Unsigned char
 #    c     |  Char
 #    D, d  |  Double-precision float, native format
 #    E     |  Double-precision float, little-endian byte order
 #    e     |  Single-precision float, little-endian byte order
 #    F, f  |  Single-precision float, native format
 #    G     |  Double-precision float, network (big-endian) byte order
 #    g     |  Single-precision float, network (big-endian) byte order
 #    H     |  Hex string (high nibble first)
 #    h     |  Hex string (low nibble first)
 #    I     |  Unsigned integer
 #    i     |  Integer
 #    L     |  Unsigned long
 #    l     |  Long
 #    M     |  Quoted printable, MIME encoding (see RFC2045)
 #    m     |  Base64 encoded string
 #    N     |  Long, network (big-endian) byte order
 #    n     |  Short, network (big-endian) byte-order
 #    P     |  Pointer to a structure (fixed-length string)
 #    p     |  Pointer to a null-terminated string
 #    Q, q  |  64-bit number
 #    S     |  Unsigned short
 #    s     |  Short
 #    U     |  UTF-8
 #    u     |  UU-encoded string
 #    V     |  Long, little-endian byte order
 #    v     |  Short, little-endian byte order
 #    w     |  BER-compressed integer\fnm
 #    X     |  Back up a byte
 #    x     |  Null byte
 #    Z     |  Same as ``a'', except that null is added with *
 # packs data in prep to write to gdal..
  def pack(data)
    pack_template = case(@band.DataType)
      when Gdal::Gdalconst::GDT_UNKNOWN;raise ArgumentError, "GDT_UNKNOWN has no storage template.. not sure what to do here folks", caller
      when Gdal::Gdalconst::GDT_BYTE; 'c'
      when Gdal::Gdalconst::GDT_UINT16;'S'
      when Gdal::Gdalconst::GDT_INT16;'s'
      when Gdal::Gdalconst::GDT_UINT32; 'I'
      when Gdal::Gdalconst::GDT_INT32; 'i'
      when Gdal::Gdalconst::GDT_FLOAT32; 'f'
      when Gdal::Gdalconst::GDT_FLOAT64; 'D'
      when Gdal::Gdalconst::GDT_CINT16; ''    #What are these? Complex types?
      when Gdal::Gdalconst::GDT_CINT32; ''    #What are these?
      when Gdal::Gdalconst::GDT_CFLOAT32; ''  #What are these?
      when Gdal::Gdalconst::GDT_CFLOAT64; '' #What are these?
      else raise ArgumentError, "Unknown datatype.. not sure what to do here folks", caller
    end
    raise(ArgumentError, "Complex type requested, but no complex type handling.. not sure what to do here folks", caller) if ( pack_template == '')
    return data.pack(pack_template*data.length)
  end
  
end

##
# Class for a file - this is what most folks want
# Use like:
#infile = GdalFile.new("foo.tif")
#bands =  infile.read_bands(0,0,infile.xsize/4,infile.ysize/4)
#..do something..
class GdalFile < GdalStuff
  def initialize ( name, mode="r", xsize=nil, ysize=nil,bands=3, driver="GTiff", data_type=String, options=['TILED=YES','COMPRESS=DEFLATE'] )
    if ( mode == "r" )
      @Gdalfile = Gdal::Gdal.open(name)
    else
      if ( mode == "w")
        if (File.exists?(name))
          @Gdalfile = Gdal::Gdal.open(name,Gdal::Gdalconst::GA_UPDATE )
        else
          driver = Gdal::Gdal.get_driver_by_name(driver)
          #puts(driver.class)
          #puts("Creating create(#{name}, #{xsize}, #{ysize}, #{bands}, #{data_type_to_gdal(data_type).to_s})")
          @Gdalfile = driver.create(name, xsize, ysize, bands, data_type_to_gdal(data_type), options)
        end
      else
        raise ArgumentError, "mode of \"#{mode}\" is not useful (not r|w) not sure what to do here folks", caller
      end
    end
    
    @bands=[]
    #1 is not a mistake - the raster bands start at 1 no 0. just a fyi.
    1.upto(@Gdalfile.RasterCount).each {|x| @bands << GdalBand.new(@Gdalfile.get_raster_band(x))}
  end
  
  ###
  # methods for Reading and writing data..
  
  #reads bands
  def read_bands(start_x, start_y, width_x, width_y)
    data = []
    @bands.each_index {|x| data[x] = @bands[x].read(start_x, start_y, width_x, width_y)}
    data
  end
  #reads a band
  def read_band(bandno,start_x, start_y,width_x, width_y  )
    @bands[bandno].read(start_x, start_y, width_x, width_y)
  end
  #writes bands
  def write_bands(start_x, start_y, width_x, width_y, bands)
    bands.each_index {|x| @bands[x].write(start_x, start_y, width_x, width_y, bands[x])}
  end
  #writes a band
  def write_band(bandno,start_x, start_y, end_x, end_y, band )
    @bands[bandno].write(start_x, start_y, end_x, end_y, band)
  end
  
  
  ###
  # getting info about the data..
  
  #returns basic size info as a hash
  def size()
    { "x"=> @Gdalfile.RasterXSize,
      "y" => @Gdalfile.RasterYSize,
      "bands" => @bands.length,
      "data_type" => @bands[0].data_type()}
  end
  
  #x dimention size
  def xsize()
    @Gdalfile.RasterXSize
  end
  
  #y dim size
  def ysize()
    @Gdalfile.RasterYSize
  end
  
  #number of bands
  def number_of_bands()
    @bands.length
  end
  
  #types of bands
  def data_type()
    @bands.first.data_type
  end
  
  #for pping or other .to_s action..
  def to_s
    "#{xsize}x#{ysize} with #{number_of_bands} #{@bands[0].to_s} bands"
  end
  
  # gets the projection
  def get_projection
    @Gdalfile.get_projection
  end
  
  #sets the projection
  def set_projection(proj_str)
    @Gdalfile.set_projection(proj_str)
  end
  
  #looks up the projection in the epsg database, give it a number like 102006.
  def set_projection_epsg(epsg)
    srs =  Gdal::Osr::SpatialReference.new()
    srs.import_from_epsg(epsg)
    @Gdalfile.set_projection(srs.export_to_wkt)
  end
  
  #sets the geo_transform, the wld file generally.
  def set_geo_transform(srs) 
    @Gdalfile.set_geo_transform(srs)
  end
  
  #gets the geo transform (wld file traditionally)
  def get_geo_transform()
     @Gdalfile.get_geo_transform
  end
  
end
