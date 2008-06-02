Ramaze::Helper::PATH.unshift(__DIR__/'../')

class AppController < Ramaze::Controller
  box = '<div class="%key" onclick="$(this).slideUp(250);">[Hide] %value</div>'
  trait :flashbox => box

  def self.inherited(klass)
    super
    klass.helper :xhtml, :config, :user, :formatting
    klass.layout '/page'
  end

  private

  def is_private?
    if logged_in? and @user.login == user.login
      request[:public] ? false : true
    end
  end

  def login_or_user(login)
    if login
      @user = User[:login => login]
    elsif logged_in?
      @user = user
    else
      nil
    end
  end
end

acquire 'controller/*.rb'
