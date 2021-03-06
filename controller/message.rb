class MessageController < Controller
  def index
    login_first

    @profile = user.profile
    @received = @profile.received_messages
    @sent = @profile.sent_messages

    @message = Message.new(request.params)

    send if request.post?
  end

  def complete
    login_first

    logins = Profile.autocomplete(request[:q])
    logins.delete user.login # don't show yourself
    respond logins.join("\n"), 200
  end

  private

  def send
    from = user.profile
    to = Profile[:login => request[:login]]

    if to and from != to
      @message.update_values(:from_id => from.id, :to_id => to.id)

      if @message.save
        flash[:good] = "Message sent"
      else
        flash[:bad] = @message.errors.full_messages
      end
    else
      flash[:bad] = "Recipient invalid"
    end
    redirect Rs()
  end
end
