class CommentController < AppController
  # comment on profile
  # TODO
  def profile(login)
    if target = User[:login => login]
      if text = request[:comment]
        comment = Comment.new(:text => text)
        target.profile.add_comment
      end
    end

    redirect_referrer
  end
end
