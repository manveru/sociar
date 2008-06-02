require 'configuration'

require 'env/sociar'
require 'env/dev'

SOCIAR = Configuration.for('sociar')

s = SOCIAR.sequel
DB = Sequel.connect s.db, :logger => s.logger
