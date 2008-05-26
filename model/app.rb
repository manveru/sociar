require 'sequel'
require 'scaffolding_extensions'

DB = Sequel.sqlite
MODELS = []

require 'model/account_mailer'
require 'model/blog'
require 'model/comment'
require 'model/feed'
require 'model/feed_item'
require 'model/friend'
require 'model/message'
require 'model/photo'
require 'model/profile'
require 'model/user'

MODELS.each do |mod|
  mod.create_table unless mod.table_exists?
end
