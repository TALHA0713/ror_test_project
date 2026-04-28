class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  # GET /users
  # def index
  #   @users = User.where.not(id: current_user.id)
  # end

  # GET /users/:id
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /users/:id/edit
  def edit
  end

  # PATCH/PUT /users/:id
  def update
    if @user.update(user_params)
      redirect_to @user, notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    @user.destroy
    redirect_to users_path, notice: "User deleted successfully."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
  params.require(:user).permit(
    :name,
    :email,
    :password,
    :password_confirmation,
    :is_active,
    :can_create_project
  )
  end
end
