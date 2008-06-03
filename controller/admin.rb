class AdminController < Ramaze::Controller
  scaffold_all_models

  helper :user, :aspect

  before_all do
    p user.is_admin
    redirect_referrer unless user.is_admin
  end
end
