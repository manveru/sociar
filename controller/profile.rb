class ProfileController < AppController
  def index(nick = nil)
    if nick
      redirect Rs(:show, nick)
    else
      @user = user
      @profile = @user.profile
    end
  end

  def show(login)
    # flash[:good] = ['something good', 'and more goodness', 'even more here']
    if login
      @user = User[:login => login]
    else
      @user = user
    end
    redirect R(:/) unless @user.login

    @profile = @user.profile
    @flickr = @profile.flickr_photos
    @comments = Comment.all
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

  def form_input(name, label = name.to_s.capitalize)
    id = "edit-#{name}"
    value = h(instance_variable_get("@#{value}"))
    %|<label for="#{id}">#{label}</label>
      <input type="text" name="#{name}" value="#{value}" id="#{id}" />|
  end
end
