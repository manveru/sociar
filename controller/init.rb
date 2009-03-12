# Add our helper directory for lookups
Ramaze::Helper::PATH.unshift(__DIR__('../'))

class Controller < Ramaze::Controller
  box = '<div class="%key" onclick="$(this).slideUp(250);">[Hide] %value</div>'
  trait :flashbox => box

  helper :xhtml, :config, :user, :formatting, :form, :gravatar, :stack
  layout '/layout'
  engine :Haml

  private

  def login_first
    return if logged_in?
    call R(AccountController, :login)
  end

  def is_private?
    if logged_in? and @user.login == user.login
      request[:public] ? false : true
    end
  end

  def login_or_user(login)
    @user = nil

    if login
      @user = User[:login => login]
    elsif logged_in?
      @user = user
    else
      nil
    end
  ensure
    @profile = @user.profile if @user
  end
end

Ramaze::acquire 'controller/{image,blog,message}.rb'
Ramaze::acquire 'controller/*.rb'
