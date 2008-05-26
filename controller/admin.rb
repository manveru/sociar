class AdminController < Ramaze::Controller
  scaffold_all_models :only => MODELS
end
