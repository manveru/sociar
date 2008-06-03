class CommentController < AppController
  # comment on profile
  # TODO
  def profile(id)
    redirect_referrer unless logged_in?
    from, to = user.profile, Profile[id]
    body = request[:comment]

    if (from and to and body) and from != to
      Comment.create :body => body, :from => from, :to => to
    end

    redirect_referrer
  end
end
