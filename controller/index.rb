class IndexController < Controller
  map '/'

  def index
    @profiles = Profile.latest
    @comments = Comment.latest
    @images = Image.latest
  end
end
