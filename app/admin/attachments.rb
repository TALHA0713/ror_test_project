# A failed ActiveAdmin reload can leave this generated controller in memory
# with the wrong superclass, which prevents routes from being redrawn.
stale_attachments_controller =
  defined?(::Admin::AttachmentsController) &&
  ::Admin::AttachmentsController.superclass != ActiveAdmin::ResourceController

if stale_attachments_controller
  ::Admin.send(:remove_const, :AttachmentsController)
end

ActiveAdmin.register Attachment, namespace: :admin do
  permit_params :ticket_id,
                :comment_id,
                :uploaded_by_user_id,
                :file_name,
                :file_path,
                :file_size,
                :mime_type

  filter :ticket_id
  filter :comment_id
  filter :uploaded_by_user_id
  filter :mime_type
  filter :created_at

  index do
    selectable_column
    id_column
    column :file_name
    column :mime_type
    column :file_size
    column :ticket_id
    column :comment_id
    column :uploaded_by_user_id
    column :created_at
    actions
  end

  form do |f|
    f.inputs "Attachment" do
      f.input :ticket_id, as: :select, collection: Ticket.order(created_at: :desc).map { |t| [ "##{t.ticket_no} - #{t.title}", t.id ] }, include_blank: true
      f.input :comment_id, as: :select, collection: Comment.order(created_at: :desc).limit(100).map { |c| [ "Comment ##{c.id}", c.id ] }, include_blank: true
      f.input :uploaded_by_user_id, as: :select, collection: User.where(is_active: true).pluck(:name, :id)
      f.input :file_name
      f.input :file_path
      f.input :file_size
      f.input :mime_type
    end

    f.actions
  end
end
