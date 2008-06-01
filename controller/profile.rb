class ProfileController < AppController
  helper :form, :gravatar

  def index(login = nil)
    if @user = login_or_user(login)
      @profile = @user.profile
      @flickr = @profile.flickr_photos
      @comments = Comment.filter(:to_id => @user.id)
      @images = @user.images

      @private = is_private?
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

  def password
    redirect_referrer unless logged_in?

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

    redirect_referrer
    p request.params
    {"new"=>"letmein", "confirm"=>"letmein", "current"=>"letmein"}
  end

  def search
    if q = request[:q]
      terms = {'login' => q}
    else
      terms = request.params
    end

    @results = [Profile, User].map{|model|
      model.search(terms)
    }.flatten.uniq
  end

  private

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
