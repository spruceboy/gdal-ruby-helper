require 'rubygems'

if File.read('lib/version.rb') =~ /Version\s+=\s+"(\d+\.\d+\.\d+)"/
  version = $1
else
  raise "no version"
end

spec = Gem::Specification.new do |s|
  s.name = 'gdal-helper'
  s.version = version
  s.summary = 'A helper library for the ruby bindings to gdal (http://gdal.org)'
  s.description = 'A helper library for the ruby bindings to gdal (http://gdal.org)'
  s.requirements << 'PostgreSQL >= 7.4'

  s.files = (Dir['lib/*'] + Dir['test/*'] +
             Dir['examples/*'])

  s.require_path = 'lib'

  s.author = "JC"
  s.email = "JC@alaska.edu"
  s.homepage = "http://www.gina.alaska.edu"
  #s.rubyforge_project = "ruby-gdal-helper"
end


