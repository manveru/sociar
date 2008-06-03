class ProfileController < AppController
  helper :form, :gravatar

  def index(login = nil)
    if @user = login_or_user(login)
      @flickr = @profile.flickr_photos
      @comments = @profile.received_comments
      @images = @profile.images

      @private = is_private?
    else
      redirect R(:/)
    end
  end

  def search
    if q = request[:q]
      terms = {'login' => q}
    else
      terms = request.params
    end

    @results = Profile.search(terms)
  end

  # FIXME: make this more strict
  def edit(section = nil)
    redirect_referrer unless logged_in?

    @profile = user.profile

    case section
    when 'general', 'openid', 'password'
      if request.post?
        send("edit_#{section}")
        redirect Rs(:edit)
      end
    end
  end

  private

  def edit_general
    @profile.update_values(request.params)
  end

  def edit_openid
    return unless oid = request['openid']
    user.update_values(:openid => oid)
  end

  def edit_password
    current, new, confirm = form = request[:current, :new, :confirm]

    if form.all?
      if form.each{|str| str.strip! }.any?{|str| str.empty? }
        flash[:bad] = "Please fill out all fields"
        redirect_referrer
      end

      if user.authenticated?(current)
        if new == confirm
          user.password = new
          user.password_confirmation = confirm
          if user.valid?
            user.crypted_password = user.encrypt(new)
            user.save
            flash[:good] = "Password changed successfully"
          end
        else
          flash[:bad] = "New password doesn't match confirmation"
        end
      else
        flash[:bad] = "Current password wrong"
      end
    end
  end

  # TODO: get rid of those
  def profile_empty?
    @profile.no_data?
  end

  def images_empty?
    @profile.images.empty?
  end

  def friends_empty?
    return true
    @profile.followings.empty? and @profile.friends.empty?
  end

  def messages_empty?
    return true
    @profile.sent_messages.empty?
  end

  def blogs_empty?
    @profile.blogs.empty?
  end
end
