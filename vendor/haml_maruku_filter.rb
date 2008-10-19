require 'maruku'
require 'haml'

module Haml::Filters::Maruku
  include Haml::Filters::Base

  def render(text)
    ::Maruku.new(text).to_html
  end
end
