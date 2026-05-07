ActiveAdmin.register Comment, namespace: :admin do
  permit_params :ticket_id, :user_id, :comment
  actions :all, except: [ :new ]

  filter :ticket_id
  filter :user_id
  filter :created_at

  index do
    selectable_column
    id_column
    column :ticket_id
    column :user_id
    column :comment
    column :created_at
    actions
  end

  form do |f|
    f.inputs "Comment" do
      f.input :ticket_id, as: :select, collection: Ticket.order(created_at: :desc).map { |t| [ "##{t.ticket_no} - #{t.title}", t.id ] }
      f.input :user_id, as: :select, collection: User.where(is_active: true).pluck(:name, :id)
      f.input :comment
    end

    f.actions
  end
end
