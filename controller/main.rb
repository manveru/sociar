class MainController < AppController
  map '/'

  def index
    @comments = Comment.latest
    @users = User.latest
    @pictures = Picture.latest
  end
end
