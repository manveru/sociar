class MessageController < AppController
  helper :form

  def index
    redirect_referrer unless logged_in?

    @profile = user.profile
    @received = @profile.received_messages
    @sent = @profile.sent_messages

    @message = Message.new(request.params)
    # @message.update_values(request.params)
  end

  def complete
    if q = request[:q]
      sql = ["login LIKE '%' || ? || '%'", q]
      logins = Profile.order(:login).where(sql).map{|profile| profile.login }
      respond logins.join("\n"), 200
    end
  end
end
