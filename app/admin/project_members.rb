ActiveAdmin.register ProjectMember, namespace: :admin do
  permit_params :project_id, :user_id, :is_active, :joined_at

  filter :project_id
  filter :user_id
  filter :is_active
  filter :joined_at

  index do
    selectable_column
    id_column
    column :project_id
    column :user_id
    column :is_active
    column :joined_at
    actions
  end

  form do |f|
    f.inputs "Project Member" do
      f.input :project_id, as: :select, collection: Project.pluck(:name, :id)
      f.input :user_id, as: :select, collection: User.where(is_active: true).pluck(:name, :id)
      f.input :is_active
      f.input :joined_at
    end

    f.actions
  end
end
