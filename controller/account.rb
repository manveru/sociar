class AccountController < Controller
  helper :simple_captcha, :identity
  layout '/minimal_layout'

  def register
    redirect_referrer if logged_in?
    @user = User.prepare(request.params)
    # they will be used in the form
    @login, @email = @user.login, @user.email

    if request.post?
      redirect_referrer unless check_captcha(request[:captcha])
      if @user.save
        flash[:good] = "You signed up, welcome on board #{@user.login}!"
        user_login('login' => @user.login)
        answer R(ProfileController, @user.login)
      end
    end
  end

  # TODO: use stack
  def login
    redirect_referrer if logged_in?
    push request.referrer unless inside_stack?

    case request[:fail]
    when 'session'
      flash[:bad] =
        'Failed to login, please make sure you have cookies enabled for this site'
    end

    return unless request.post?

    if user_login
      flash[:good] = "Welcome back #{user.login}"
      redirect Rs(:after_login)
    end
  end

  # TODO: use stack
  def openid
    redirect_referrer if logged_in?

    @oid = session[:openid_identity]
    @url = request[:url] || @oid

    if @oid
      openid_finalize
    elsif request.post?
      openid_begin
    else
      flash[:bad] = flash[:error] || "Bleep"
    end
  end

  # This method is simply to check whether we really did login and the browser
  # sends us a cookie, if we're not logged in by now it would indicate that the
  # client doesn't support cookies or has it disabled and so unable to use this
  # site.
  # For some reason, the arora seems to have problems handling cookies on
  # localhost from rack.
  def after_login
    if logged_in?
      answer R(ProfileController, user.login)
    else
      redirect Rs(:login, :fail => :session)
    end
  end

  def logout
    user_logout

    [:openid, :openid_identity, :openid_sreg].each do |sym|
      session.delete(sym)
    end

    flash[:good] = "You logged out successfully"

    redirect R(:/)
  end

  private

  def openid_finalize
    if user_login('openid' => @oid)
      flash[:good] = flash[:success]
      redirect R(ProfileController, user.login)
    else
      flash[:bad] = "None of our users belongs to this OpenID"
    end
  end
end
