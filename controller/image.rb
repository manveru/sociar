class ImageController < AppController
  helper :form

  def index(login = nil)
    if @user = login_or_user(login)
      @images = @profile.images
      @private = is_private?
    else
      redirect R(:/)
    end
  end

  def save
    redirect_referrer unless logged_in? and request.post?

    image = Image.store(user.profile, request)

    redirect_referrer
  end

  def delete(id)
    if image = Image[id]
      if image.profile_id == user.profile_id
        image.delete
      end
    end

    redirect_referrer
  end
end
