class CommentController < Controller
  # comment on profile
  # TODO
  def profile(id)
    login_first

    from, to = user.profile, Profile[id]
    body = request[:comment]

    if (from and to and body) and from != to
      Comment.create :body => body, :from => from, :to => to
    end

    redirect_referrer
  end
end
