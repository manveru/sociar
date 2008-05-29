Ramaze::Route[%r!/css/(.+)\.css!] = '/css/%s'

class CssController < Ramaze::Controller
  engine :Sass
end
