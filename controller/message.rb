class MessageController < AppController
  helper :form

  def index
    redirect_referrer unless logged_in?

    @profile = user.profile
    @received = @profile.received_messages
    @sent = @profile.sent_messages

    @message = Message.new(request.params)

    send if request.post?
  end

  def complete
    redirect_referrer unless logged_in?

    logins = Profile.autocomplete(request[:q])
    logins.delete user.login # don't show yourself
    respond logins.join("\n"), 200
  end

  private

  def send
    from = user.profile

    if to = Profile[:login => request[:login]]
      @message.update_values(:from_id => from.id, :to_id => to.id)
      if @message.save
        flash[:good] = "Message sent"
      else
        flash[:bad] = @message.errors.full_messages
      end
    end
    redirect Rs()
  end
end
