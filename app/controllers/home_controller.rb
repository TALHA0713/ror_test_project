class HomeController < ApplicationController
  def index
    return unless logged_in?

    project_ids = @sidebar_projects.map(&:id)
    base = Ticket.where(project_id: project_ids)

    accessible =
      if current_user.manager?
        base
      else
        base.where(assigned_to_user_id: current_user.id)
            .or(base.where(created_by_user_id: current_user.id))
            .distinct
      end

    counts = accessible.group(:status).count
    @open_count       = counts["open"].to_i
    @in_progress_count = counts["in_progress"].to_i
    @resolved_count   = counts["resolved"].to_i
    @closed_count     = counts["closed"].to_i
    @total_count      = accessible.count
    @recent_tickets   = accessible.includes(:project, :assigned_to_user)
                                  .order(updated_at: :desc).limit(5)
  end
end
