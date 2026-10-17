class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_authentication
    return if logged_in?

    redirect_to login_path, alert: "Devam etmek için giriş yapmalısınız."
  end

  def require_employee
    return if current_user&.employee?

    head :forbidden
  end

  def require_manager
    return if current_user&.manager?

    head :forbidden
  end

  def render_not_found
    head :not_found
  end
end
