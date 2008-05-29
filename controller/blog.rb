class BlogController < AppController
  def index(login = nil, title = nil)
    @user = User[:login => 'manveru']

    if title
      @blog = Blog[:title => title]
    else
      @blogs = @user.profile.blogs
    end

    return

    if @user = User[:login => login]
    else
      redirect_referrer
    end
  end
end
