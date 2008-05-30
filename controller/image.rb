class ImageController < AppController
  def index(login = nil)
    if @user = login_or_user(login)
      @images = @user.images
      @private = is_private?
    else
      redirect R(:/)
    end
  end

  def manage
  end
end
