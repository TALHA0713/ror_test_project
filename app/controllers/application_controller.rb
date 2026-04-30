class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  allow_browser versions: :modern
  stale_when_importmap_changes
  helper_method :current_user, :logged_in?, :manager_for_project?, :can_access_ticket?, :can_edit_ticket?

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

  def active_project_member_for(project)
    current_user&.active_project_member_for(project)
  end

  def role_names_for(project)
    current_user ? current_user.role_names_for(project) : []
  end

  def manager_for_project?(project)
    current_user&.manager_for_project?(project)
  end

  def can_work_on_project?(project)
    role_names_for(project).any?
  end

  def can_access_ticket?(ticket)
    # if user is not active member of that ticket’s project, then cannot access
    return false unless active_project_member_for(ticket.project)
    # if user is manager of this project or current user is assinged to this ticket, then can access
    manager_for_project?(ticket.project) || ticket.assigned_to_user_id == current_user.id || ticket.created_by_user_id == current_user.id
  end

  def can_edit_ticket?(ticket)
    can_access_ticket?(ticket)
  end

  def render_not_found
    render "errors/not_found", status: :not_found
  end
end

# gems devise
