ActiveAdmin.register User, namespace: :admin do
  permit_params :name, :email, :role, :is_active, :password, :password_confirmation

  filter :name
  filter :email
  filter :role
  filter :is_active
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :role
    column :is_active
    column :created_at
    actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :name
      f.input :email
      f.input :role, as: :select, collection: [ "manager", "developer", "qa" ]
      f.input :is_active
      f.input :password
      f.input :password_confirmation
    end

    f.actions
  end

  controller do
    def update
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      super
    end
  end
end
