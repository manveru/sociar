require 'configuration'

require "env/sociar"
begin
  require "env/#{SOCIAR.mode}"
  require "env/#{SOCIAR.host}"
rescue LoadError => ex
  Ramaze::Log.warn ex
end

s = SOCIAR.sequel
DB = Sequel.connect s.db, :logger => s.logger
