require 'rubygems'
require 'ramaze'
require 'maruku'
require 'sequel'
require 'scaffolding_extensions'

$LOAD_PATH.unshift(__DIR__)

require 'env'
require 'vendor/flickr'
require 'vendor/image_science_cropped_resize'
acquire 'model/*.rb'
require 'controller/app'

require 'db/init' if SOCIAR.mode == 'dev'

r = SOCIAR.ramaze
Ramaze.start :adapter => r.adapter,
             :host => r.host,
             :port => r.port,
             :boring => r.boring
