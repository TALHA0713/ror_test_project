class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :role, :string

    execute <<~SQL
      UPDATE users SET role = 'manager' WHERE can_create_project = TRUE;
      UPDATE users SET role = 'developer' WHERE can_create_project = FALSE OR can_create_project IS NULL;
    SQL

    change_column_null :users, :role, false
    add_check_constraint :users,
      "role::text = ANY (ARRAY['manager'::character varying, 'developer'::character varying, 'qa'::character varying]::text[])",
      name: "user_role"
  end

  def down
    remove_check_constraint :users, name: "user_role"
    remove_column :users, :role
  end
end
