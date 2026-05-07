ActiveAdmin.register Project, namespace: :admin do
  permit_params :name, :description, :created_by_user_id

  filter :name
  filter :created_by_user_id
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :created_by_user_id
    column :created_at
    actions
  end

  form do |f|
    f.inputs "Project Details" do
      f.input :name
      f.input :description
      f.input :created_by_user_id,
              as: :select,
              collection: User.where(role: "manager", is_active: true).pluck(:name, :id)
    end

    f.actions
  end
end
