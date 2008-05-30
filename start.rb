require 'rubygems'
require 'ramaze'
require 'ramaze/helper/gravatar'

$LOAD_PATH.unshift(__DIR__/:vendor)
Ramaze::Helper::PATH.unshift(__DIR__)

require 'maruku'
require 'flickr'

FLICKR = Flickr.new(File.read('/home/manveru/.flickr_api_key').strip)

require 'model/app'
require 'controller/app'

CONFIGURATION = Struct.new(:site_name).new('Sociar')

if $0 == __FILE__
  require 'init'
end

Ramaze.start :adapter => :thin
