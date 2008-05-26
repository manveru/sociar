class AppController < Ramaze::Controller
  box = '<div class="%key" onclick="$(this).slideUp(250);">%value</div>'
  trait :flashbox => box

  def self.inherited(klass)
    super
    klass.helper :xhtml, :config, :user
    klass.layout '/page'
  end
end

require 'controller/main'
require 'controller/account'
require 'controller/admin'
require 'controller/blog'
require 'controller/comment'
require 'controller/feed'
require 'controller/friend'
require 'controller/home'
require 'controller/message'
require 'controller/photo'
require 'controller/profile'
