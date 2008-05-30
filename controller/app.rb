class AppController < Ramaze::Controller
  box = '<div class="%key" onclick="$(this).slideUp(250);">[Hide] %value</div>'
  trait :flashbox => box

  def self.inherited(klass)
    super
    klass.helper :xhtml, :config, :user, :formatting
    klass.layout '/page'
  end
end

require 'controller/account'
require 'controller/admin'
require 'controller/blog'
require 'controller/comment'
require 'controller/css'
require 'controller/feed'
require 'controller/friend'
require 'controller/home'
require 'controller/main'
require 'controller/message'
require 'controller/image'
require 'controller/profile'
