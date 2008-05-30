class ProfileController < AppController
  helper :form, :gravatar

  def index(login = nil)
    if login
      @user = User[:login => login]
    elsif logged_in?
      @user = user
    else
      redirect R(:/)
    end

    redirect R(:/) unless @user and @user.login

    @profile = @user.profile
    @flickr = @profile.flickr_photos
    @comments = Comment.filter(:to_id => @user.id)
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

  private

  def profile_item(title, value)
    return '' unless value
    %|<tr><td class="key">#{title}:</td><td class="value">#{value}</td></tr>|
  end

  def profile_empty?
    @profile.no_data?
  end

  def photos_empty?
    return true
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
