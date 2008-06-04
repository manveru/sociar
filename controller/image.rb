class ImageController < AppController
  def index(login = nil)
    if @user = login_or_user(login)
      @images = @profile.images
      @private = is_private?
    else
      redirect R(:/)
    end
  end

  def save
    login_first

    if request.post?
      image = Image.store(user.profile, request)
    end

    redirect_referrer
  end

  def delete(id)
    login_first

    if image = Image[id]
      if image.profile_id == user.profile_id
        image.delete
      end
    end

    redirect_referrer
  end
end
