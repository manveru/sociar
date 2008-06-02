require 'configuration'

require 'env/sociar'
require 'env/dev'

SOCIAR = Configuration.for('sociar')

DB = Sequel.connect SOCIAR.sequel.db
