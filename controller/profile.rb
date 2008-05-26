class ProfileController < AppController
  def index
  end

  def show(login = nil)
    if login
      @user = User[:login => login]
    else
      @user = user
    end
    redirect R(:/) unless @user.login

    @profile = @user.profile
  end

  private

  def profile_item(title, value)
    return '' unless value
    %|<b class="grid_3">#{title}</b> <p class="grid_7">#{value}</p>|
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
