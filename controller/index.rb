class IndexController < AppController
  map '/'

  def index
    @profiles = Profile.latest
    @comments = Comment.latest
    @images = Image.latest
  end
end
