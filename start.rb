require 'rubygems'
require 'ramaze'

require 'maruku'

Ramaze::Helper::PATH.unshift(__DIR__)

require 'model/app'
require 'controller/app'

CONFIGURATION = Struct.new(:site_name).new('Sociar')

if $0 == __FILE__
  user = User.prepare('email' => 'm.fellinger@gmail.com',
                      'password' => 'letmein',
                      'password_confirmation' => 'letmein',
                      'login' => 'manveru')
  user.save
  user.post_create
  profile = user.profile
  profile.about_me = "This open social network is brought to you by manveru."
  profile.website = 'http://manveru.net'
  profile.blog = "http://manveru.net"
  profile.flickr = "http://flickr.com/photos/manveru"
  profile.aim_name = 'feagliir'
  profile.gtalk_name = 'm.fellinger@gmail.com'
  user.profile.save
end

Ramaze.start :adapter => :thin
