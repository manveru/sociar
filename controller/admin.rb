class AdminController < Ramaze::Controller
  scaffold_all_models

  helper :user, :aspect

  before_all do
    redirect_referrer unless user.is_admin
  end
end
