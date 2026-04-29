class ProjectsController < ApplicationController
  before_action :require_login
  before_action :require_project_creator, only: [ :new, :create, :edit, :update, :destroy, :remove_member ]
  before_action :set_project, only: [ :show, :edit, :update, :destroy, :remove_member ]

  def index
    @projects =
      if current_user.can_create_project?
        current_user.created_projects.includes(project_members: :user)
      else
        Project
          .joins(:project_members)
          .where(project_members: { user_id: current_user.id, is_active: true })
          .includes(project_members: :user)
          .distinct
      end
  end

  def show
    @project_members = @project.project_members.includes(:user, :roles)
  end

  def new
    @project = Project.new
    @users = User.where.not(id: current_user.id)
  end

  def create
    @project = current_user.created_projects.build(project_params)

    if @project.save
      create_creator_as_manager
      sync_project_members

      redirect_to project_path(@project), notice: "Project created successfully."
    else
      @users = User.where.not(id: current_user.id)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @users = User.where.not(id: current_user.id)
    @project_members = @project.project_members.includes(:user, :roles)
  end

  def update
    if @project.update(project_params)
      create_creator_as_manager
      sync_project_members

      redirect_to @project, notice: "Project updated successfully."
    else
      @users = User.where.not(id: current_user.id)
      @project_members = @project.project_members.includes(:user, :roles)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted successfully."
  end

  def remove_member
    member = @project.project_members.find_by(user_id: params[:user_id])

    if member&.user == current_user
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
      if current_user.can_create_project?
        current_user.created_projects.find(params[:id])
      else
        Project
          .joins(:project_members)
          .where(project_members: { user_id: current_user.id, is_active: true })
          .distinct
          .find(params[:id])
      end
  end

  def require_project_creator
    unless current_user.can_create_project?
      redirect_to root_path, alert: "You are not allowed to manage projects."
    end
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end

  def allowed_member_roles
    %w[developer qa]
  end

  def manager_role
    Role.find_by!(name: "manager")
  end

  def role_by_name(name)
    Role.find_by!(name: name)
  end

  def selected_user_ids
    Array(params[:project_user_ids]).reject(&:blank?)
  end

  def user_roles_params
    params[:user_roles] || {}
  end

  def creator_role_names
    Array(params[:creator_roles]).reject(&:blank?) & allowed_member_roles
  end

  def create_creator_as_manager
    creator_member = @project.project_members.find_or_create_by!(user: current_user)

    # Creator is always manager
    ProjectMemberRole.find_or_create_by!(
      project_member: creator_member,
      role: manager_role
    )

    # Creator can also be developer / QA
    sync_roles_for_member(creator_member, creator_role_names, keep_manager: true)
  end

  def sync_project_members
    # Remove unselected users, but never remove creator
    @project.project_members
            .where.not(user_id: selected_user_ids)
            .where.not(user_id: current_user.id)
            .destroy_all

    selected_user_ids.each do |user_id|
      member = @project.project_members.find_or_create_by!(user_id: user_id)

      selected_roles = Array(user_roles_params[user_id]).reject(&:blank?) & allowed_member_roles

      sync_roles_for_member(member, selected_roles, keep_manager: false)
    end
  end

  def sync_roles_for_member(member, selected_roles, keep_manager:)
    # Remove developer / QA roles first
    member.project_member_roles
          .joins(:role) 
          .where(roles: { name: allowed_member_roles })
          .destroy_all

    # Remove manager role from everyone except creator
    unless keep_manager
      member.project_member_roles
            .joins(:role)
            .where(roles: { name: "manager" })
            .destroy_all
    end

    selected_roles.each do |role_name|
      ProjectMemberRole.find_or_create_by!(
        project_member: member,
        role: role_by_name(role_name)
      )
    end
  end
end
