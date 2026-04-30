class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_ticket
  before_action :ensure_ticket_access

  def create
    @comment = @ticket.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      Attachment.save_files_for(@comment, params[:comment][:files], current_user)
      redirect_to ticket_path(@ticket), notice: "Message sent successfully."
    else
      @comments = @ticket.comments.includes(:user, :attachments).order(:created_at)
      @attachments = @ticket.attachments.order(created_at: :desc)
      render "tickets/show", status: :unprocessable_entity
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  end

  def ensure_ticket_access
    return if can_access_ticket?(@ticket)

    redirect_to tickets_path, alert: "You are not allowed to view this ticket."
  end

  def comment_params
    params.require(:comment).permit(:comment)
  end
end
