class ProfileController < AppController
  helper :gravatar

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
      terms = {'login' => q, 'name' => q}
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

  def blurps
    @profile = user.profile

    BLURPS.map{|section|
      @name, @link, @title, @text = section
      @img = "/media/blurp/#{@name.downcase}.png"

      render_template('_blurp.xhtml') # if @profile.send("#{@name}_empty?")
    }.compact.join("\n")
  end

  BLURPS = [
    [ 'profile', R(self, :edit), 'Set up your profile',
      'Your public profile is the way your friends will learn about you and keep up-to-date on your life. Upload a profile photo, add an "about me", connect with new and old friends.' ],

    [ 'images', R(ImageController), 'Share photos, drawings, sketches...',
      'You can upload images with captions to your profile. Build albums, tag and comment on images!' ],

    [ 'friends', R(:/), 'Find friends',
      "Finding your friends is easy, get started by searching for profiles on #{config.title}." ],

    [ 'messages', R(MessageController), 'Message friends',
      "Exchange messages with friends and other people on #{config.title}. We already sent you a message to get you started." ],

    [ 'blog', R(BlogController), 'Start blogging',
      "Share your thoughts with the world, no matter if you want to write whole essays or just a little something about how you feel." ],
  ]
end
