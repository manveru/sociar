class ProfileController < AppController
  helper :form, :gravatar

  def index(login = nil)
    if login
      @user = User[:login => login]
    elsif logged_in?
      @user = user
    end

    if @user and @user.login
      @profile = @user.profile
      @flickr = @profile.flickr_photos
      @comments = Comment.filter(:to_id => @user.id)

      if logged_in? and @user.login == user.login
        @private = !request[:public]
      else
        @private = false
      end
    else
      redirect R(:/)
    end
  end

  # FIXME: make this more strict
  def edit
    redirect_referrer unless logged_in?
    @profile = user.profile

    if request.post?
      pp request.params
      @profile.update_values(request.params)
    end
  end

  def search
    @results = [Profile, User].map{|model|
      model.search(request.params)
    }.flatten.uniq
  end

  private

  def profile_empty?
    @profile.no_data?
  end

  def photos_empty?
    @profile.photos.empty?
  end

  def friends_empty?
    return true
    @profile.followings.empty? and @profile.friends.empty?
  end

  def messages_empty?
    return true
    @profile.sent_messages.empty?
  end
end
