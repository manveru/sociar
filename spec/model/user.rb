require 'sequel'
DB = Sequel.sqlite
require 'model/user'

User.create_table

user = User.create(:login => 'manveru')
user.remember_me

p user.profile
