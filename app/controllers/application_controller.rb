class ApplicationController < ActionController::Base
  # After sign out path
  def after_sign_out_path_for(resource_or_scope)
    root_path # Redirects to the home page after logout
  end

  # Handle non-existing routes and redirect to the home page
  def not_found
    flash[:alert] = "The page you are looking for does not exist. You have been redirected to the home page."
    redirect_to root_path
  end
end
