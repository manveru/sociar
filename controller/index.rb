class IndexController < AppController
  map '/'

  def index
    @comments = Comment.latest
    @users = User.latest
    @images = Image.latest
  end
end
