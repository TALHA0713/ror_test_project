class AddCanCreateProjectToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :can_create_project, :boolean, default: false, null: false
  end
end
