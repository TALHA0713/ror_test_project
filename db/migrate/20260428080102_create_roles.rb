class CreateRoles < ActiveRecord::Migration[8.1]
    def change
        create_table :roles do |t|
            t.string :name, null: false
            t.timestamps
        end

        add_index :roles, :name, unique: true
        add_check_constraint :roles,
                            "name IN ('manager', 'qa', 'developer')",
                            name: "roles"
    end
end
