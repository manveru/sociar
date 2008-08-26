class CssController < Ramaze::Controller
  engine :Sass
end

Ramaze::Route[%r!/css/(.+)\.css!] = '/css/%s'
