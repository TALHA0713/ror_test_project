class ProjectsController < ApplicationController
  before_action :require_login
  before_action :require_manager, only: [ :new, :create, :edit, :update, :destroy, :remove_member ]
  before_action :set_project, only: [ :show, :edit, :update, :destroy, :remove_member ]

  def index
    @projects =
      if current_user.manager?
        # includes: “Load related data in advance to avoid extra database queries.”
        current_user.created_projects.includes(:tickets, project_members: :user)
      else
        Project
          .joins(:project_members)
          .where(project_members: { user_id: current_user.id, is_active: true })
          .includes(:tickets, project_members: :user)
          .distinct
      end
  end

  def show
    @project_members = @project.project_members.includes(:user)
    base = @project.tickets.includes(:created_by_user, :assigned_to_user).order(:created_at)
    all_tickets =
      if current_user.manager?
        base
      else
        base.where(assigned_to_user_id: current_user.id)
            .or(base.where(created_by_user_id: current_user.id))
            .distinct
      end
    @tickets_by_status = { "open" => [], "in_progress" => [], "resolved" => [], "closed" => [] }
    all_tickets.each { |t| @tickets_by_status[t.status] << t }
  end

  def new
    @project = Project.new
    @users = User.where.not(id: current_user.id)
  end

  def create
    @project = current_user.created_projects.build(project_params)

    if @project.save
      ensure_creator_is_member
      sync_project_members

      redirect_to project_path(@project), notice: "Project created successfully."
    else
      @users = User.where.not(id: current_user.id)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @users = User.where.not(id: current_user.id)
    @project_members = @project.project_members.includes(:user)
  end

  def update
    if @project.update(project_params)
      ensure_creator_is_member
      sync_project_members

      redirect_to @project, notice: "Project updated successfully."
    else
      @users = User.where.not(id: current_user.id)
      @project_members = @project.project_members.includes(:user)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted successfully."
  end

  def remove_member
    member = @project.project_members.find_by(user_id: params[:user_id])

    if member&.user_id == @project.created_by_user_id
      return redirect_to edit_project_path(@project), alert: "Project creator cannot be removed."
    end

    if member
      member.destroy
      redirect_to edit_project_path(@project), notice: "Member removed successfully."
    else
      redirect_to edit_project_path(@project), alert: "Member not found."
    end
  end

  private

  def set_project
    @project =
      if current_user.manager?
        # find project only from projects created by current user, to prevent unauthorized access
        current_user.created_projects.find(params[:id])
      else
        # find only thoese projects where user is assigned as active member, to prevent unauthorized access
        Project
          .joins(:project_members)
          .where(project_members: { user_id: current_user.id, is_active: true })
          .distinct
          .find(params[:id])
      end
  end

  def require_manager
    unless current_user.manager?
      redirect_to root_path, alert: "Only managers can manage projects."
    end
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end

  def selected_user_ids
    Array(params[:project_user_ids]).reject(&:blank?)
  end

  def ensure_creator_is_member
    @project.project_members.find_or_create_by!(user: current_user)
  end

  def sync_project_members
    # Remove unselected users, but never remove creator
    @project.project_members
            .where.not(user_id: selected_user_ids)
            .where.not(user_id: current_user.id)
            .destroy_all

    valid_user_ids = User
      .where(id: selected_user_ids)
      .where.not(role: "manager")
      .pluck(:id)

    valid_user_ids.each do |user_id|
      @project.project_members.find_or_create_by!(user_id: user_id)
    end
  end
end
