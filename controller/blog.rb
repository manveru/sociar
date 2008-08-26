class BlogController < Controller
  def index(login = nil, title = nil)
    @user = login_or_user(login)
    @blogs = @profile.blogs

    if title
      id = title[/^(\d+)-/, 1]
      @blog = Blog[id]
    end
  end

  def edit(id)
    login_first

    @user, @profile = user, user.profile
    redirect_referrer unless @post = Blog[id]
    @legend = "Edit Post"
    @submit = "Update Post"

    save
  end

  def new
    login_first

    @user, @profile = user, user.profile
    @post = Blog.new(:profile => @profile)
    @legend = "New Post"
    @submit = "Create Post"

    save
  end

  template :new, :edit

  private

  def save
    if request.post?
      @post.title = request[:title]
      @post.body = request[:body]
      if @post.save
        flash[:good] = "Created post"
        redirect Rs(:/, @post.to_url)
      else
        flash[:bad] = "Couldn't create post"
      end
    end
  end
end
