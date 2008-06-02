require 'rubygems'
require 'ramaze'
require 'maruku'
require 'sequel'
require 'scaffolding_extensions'

require __DIR__/'vendor/flickr'
require __DIR__/'settings'

require __DIR__/'model/app'
require __DIR__/'controller/app'

if $0 == __FILE__
  require __DIR__/'db/init'
end

Ramaze.start :adapter => :thin
