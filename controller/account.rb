class AccountController < AppController
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
        redirect R(ProfileController, @user.login)
      end
    end
  end

  # TODO: use stack
  def login
    redirect_referrer if logged_in?
    return unless request.post?
    if user_login
      flash[:good] = "Welcome back #{user.login}"
      redirect R(ProfileController, user.login)
    end
  end

  # TODO: use stack
  def openid
    redirect_referrer if logged_in?

    @oid = session[:openid_identity]
    @url = request[:url] || @oid

    if @oid
      p @oid
      openid_finalize
    elsif request.post?
      openid_begin
    else
      flash[:bad] = flash[:error] || "Bleep"
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
