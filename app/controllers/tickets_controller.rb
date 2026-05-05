class TicketsController < ApplicationController
  before_action :require_login
  before_action :set_ticket, only: [ :show, :edit, :update, :update_status ]
  before_action :set_ticket_projects, only: [ :index, :new, :create ]
  before_action :set_project_locked, only: [ :new, :create ]
  before_action :set_form_data, only: [ :new, :create, :edit, :update ]

  def index
    @status_filter = params[:status].presence
    @priority_filter = params[:priority].presence
    @project_filter = params[:project_id].presence
    @ticket_scope_filter = params[:ticket_scope].presence
    @tickets = filtered_tickets
  end

  def show
    ensure_ticket_access!
    return if performed?

    @comment = Comment.new
    @comments = @ticket.comments.includes(:user, :attachments).order(:created_at)
    @attachments = @ticket.attachments.order(created_at: :desc)
  end

  def new
    if @ticket_projects.empty?
      redirect_to tickets_path, alert: "You do not have any associated project."
      return
    end

    default_project_id = params[:project_id].presence || @ticket_projects.first.id
    @ticket = Ticket.new(project_id: default_project_id)
  end

  def create
    if @ticket_projects.empty?
      redirect_to tickets_path, alert: "You do not have any associated project."
      return
    end

    @ticket = Ticket.new(create_ticket_params)
    @ticket.created_by_user = current_user

    # it check user is valid for creating ticket in that project or not, because project_id is coming from form and user can manipulate that
    unless project_allowed_for_ticket?(@ticket.project)
      @ticket.errors.add(:project_id, "is not available for you")
      render :new, status: :unprocessable_entity
      return
    end

    if @ticket.save
      # Attachment.save_files_for(@ticket, params[:ticket][:files], current_user)
      Attachment.save_files_for(@ticket, params.dig(:ticket, :files), current_user)
      redirect_to ticket_path(@ticket), notice: "Ticket created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update_status
    ensure_ticket_access!
    return if performed?

    new_status = params[:status].to_s
    unless Ticket.statuses.key?(new_status)
      render json: { success: false, error: "Invalid status" }, status: :unprocessable_entity
      return
    end

    if @ticket.update(status: new_status)
      render json: { success: true, status: new_status }
    else
      render json: { success: false, errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit
    ensure_ticket_edit_access!
    nil if performed?
  end

  def update
    ensure_ticket_edit_access!
    return if performed?

    if @ticket.update(update_ticket_params)
      # Attachment.save_files_for(@ticket, params[:ticket][:files], current_user)
      Attachment.save_files_for(@ticket, params.dig(:ticket, :files), current_user)
      redirect_to ticket_path(@ticket), notice: "Ticket updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end
  # return list of project where current user is active memeber
  def set_ticket_projects
    @ticket_projects =
      Project
        .joins(:project_members)
        .where(project_members: { user_id: current_user.id, is_active: true })
        .includes(:users)
        .order(:name)
        .distinct
  end

    def set_project_locked
      params[:project_id].present? || params[:locked_project_id].present?
    end

    def set_form_data
      # show users of that ticket’s project
      if action_name.in?([ "edit", "update" ]) && @ticket
        # edit/update: show only the users that belong to this ticket’s project
        @assignable_users = @ticket.project.assignable_users
      elsif @project_locked
        # new/create with a fixed project: show users for that one project
        locked_id = (params[:project_id] || params[:locked_project_id]).to_i
        locked_project = @ticket_projects.find { |p| p.id == locked_id }
        @assignable_users = locked_project&.assignable_users || []
      else
        # new/create without a locked project: group users by project for dynamic dropdown
        @project_users_by_id = {}
        @ticket_projects.each do |project|
          @project_users_by_id[project.id] =
            project.assignable_users.map { |user| [ user.name, user.id ] }
        end
      end
    end

  def filtered_tickets
    tickets = accessible_tickets
    tickets = tickets.where(status: @status_filter) if @status_filter.present?
    tickets = tickets.where(priority: @priority_filter) if @priority_filter.present?
    tickets = tickets.where(project_id: @project_filter) if @project_filter.present?

    if @ticket_scope_filter == "assigned_to_me"
      tickets = tickets.where(assigned_to_user_id: current_user.id)
    elsif @ticket_scope_filter == "created_by_me"
      tickets = tickets.where(created_by_user_id: current_user.id)
    end

    tickets.ordered
  end

  def accessible_tickets
    allowed_project_ids = @ticket_projects.map(&:id)
    assigned_tickets = Ticket.where(project_id: allowed_project_ids, assigned_to_user_id: current_user.id)
    created_tickets  = Ticket.where(project_id: allowed_project_ids, created_by_user_id: current_user.id)

    if current_user.manager?
      Ticket.where(project_id: allowed_project_ids).or(assigned_tickets).or(created_tickets).distinct
    else
      assigned_tickets.or(created_tickets).distinct
    end
  end

  def create_ticket_params
    params.require(:ticket).permit(
      :project_id,
      :title,
      :description,
      :ticket_type,
      :status,
      :priority,
      :assigned_to_user_id,
      :due_date
    )
  end

  def update_ticket_params
    params.require(:ticket).permit(
      :title,
      :description,
      :ticket_type,
      :status,
      :priority,
      :assigned_to_user_id,
      :due_date
    )
  end

  def project_allowed_for_ticket?(project)
    # present check value exist or not
    # it checks the user project list cotains the porject id for creating ticket or not, because project_id is coming from form and user can manipulate that
    project.present? && @ticket_projects.any? { |ticket_project| ticket_project.id == project.id }
  end

  def ensure_ticket_access!
    return if can_access_ticket?(@ticket)

    redirect_to tickets_path, alert: "You are not allowed to view this ticket."
  end

  def ensure_ticket_edit_access!
    return if can_edit_ticket?(@ticket)

    redirect_to tickets_path, alert: "You are not allowed to update this ticket."
  end
end
