require 'rubygems'
require 'ramaze'
require 'maruku'
require 'sequel'

$LOAD_PATH.unshift(__DIR__)

require 'env'

require 'vendor/flickr'
require 'vendor/haml_maruku_filter'
require 'vendor/image_science_cropped_resize'

require 'model/init'
require 'controller/init'

# require 'db/init' if SOCIAR.mode == 'dev'

r = SOCIAR.ramaze

=begin
if r.gzip
  require 'ramaze/contrib/gzip_filter'
  gzip = Ramaze::Filter::Gzip
  gzip.trait :threshold => 1
  Ramaze::Dispatcher::Action::FILTER << gzip
=end

Ramaze.start :adapter => r.adapter,
             :host => r.host,
             :port => r.port,
             :boring => r.boring
