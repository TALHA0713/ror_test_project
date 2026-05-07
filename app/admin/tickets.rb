ActiveAdmin.register Ticket, namespace: :admin do
  permit_params :project_id,
                :assigned_to_user_id,
                :created_by_user_id,
                :title,
                :description,
                :ticket_no,
                :ticket_type,
                :priority,
                :status,
                :due_date,
                :closed_at

  filter :project_id
  filter :assigned_to_user_id
  filter :created_by_user_id
  filter :status
  filter :priority
  filter :ticket_type
  filter :due_date
  filter :created_at

  index do
    selectable_column
    id_column
    column :ticket_no
    column :title
    column :project_id
    column :status
    column :priority
    column :ticket_type
    column :assigned_to_user_id
    column :due_date
    column :created_at
    actions
  end

  form do |f|
    f.inputs "Ticket Details" do
      f.input :project_id, as: :select, collection: Project.pluck(:name, :id)
      f.input :created_by_user_id, as: :select, collection: User.where(is_active: true).pluck(:name, :id)
      f.input :assigned_to_user_id, as: :select, collection: User.where(is_active: true).pluck(:name, :id), include_blank: true

      f.input :ticket_no
      f.input :title
      f.input :description
      f.input :ticket_type, as: :select, collection: [ "bug", "feature", "task" ]
      f.input :priority, as: :select, collection: [ "low", "medium", "high", "urgent" ]
      f.input :status, as: :select, collection: [ "open", "in_progress", "resolved", "closed" ]
      f.input :due_date
      f.input :closed_at
    end

    f.actions
  end
end
