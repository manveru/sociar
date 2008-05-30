class CommentController < AppController
  # comment on profile
  # TODO
  def profile(login)
    from, to = user, User[:login => login]

    if from and to and from.id != to.id
      Comment.new(:text => request[:comment], :from=> from, :to => to)
      p from => to
      p request[:comment]
    end

    redirect_referrer
  end
end
