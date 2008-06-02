require 'configuration'

require "env/sociar"
require "env/#{SOCIAR.mode}"

host_conf = "env/#{`hostname`.strip}.rb"
require host_conf if File.file?(host_conf)

s = SOCIAR.sequel
DB = Sequel.connect s.db, :logger => s.logger
