class MainController < AppController
  map '/'

  def index
    glob = 'public/media/pictures/*_medium.png'
    @pictures = Dir[glob].first(10).map do |pub|
      base = File.basename(pub)
      '/media/pictures'/base
    end

    @users = User.all

    @featured = User[:login => 'manveru']

    @comments = Comment.all
  end
end
