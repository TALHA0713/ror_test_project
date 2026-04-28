class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes
  helper_method :current_user, :logged_in?

  private

  def current_user
    # ||= Assign value only if it’s nil or not set
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Please login first."
    end
  end
end
