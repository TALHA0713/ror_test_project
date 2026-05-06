class AddUpdateProjectToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :update_project, :string
  end
end
