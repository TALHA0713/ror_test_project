class SessionsController < ApplicationController
  def new
  end

  def create
    if params[:email].blank? || params[:password].blank?
      flash.now[:alert] = "Please enter email and password."
      return render :new, status: :unprocessable_entity
    end

    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Login successful."
    else
      flash.now[:alert] = "Please enter the correct email and password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Logged out successfully."
  end
end
