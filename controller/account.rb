class AccountController < AppController
  helper :user

  def register
    @user = User.prepare(request.params)
    # they will be used in the form
    @login, @email = @user.login, @user.email

    if request.post?
      if @user.save
        @user.post_create
        flash[:good] = "You signed up, welcome on board #{@user.login}!"
        user_login('login' => @user.login)
        redirect R(ProfileController, @user.login)
      end
    end
  end

  def login
    return unless request.post?
    if user_login
      flash[:good] = "Welcome back #{user.login}"
      redirect R(ProfileController, user.login)
    end
  end

  def logout
    user_logout
    flash[:good] = "You logged out successfully"
    redirect R(:/)
  end
end
