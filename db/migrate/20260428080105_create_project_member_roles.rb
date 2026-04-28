class CreateProjectMemberRoles < ActiveRecord::Migration[8.1]
    def change
        create_table :project_member_roles do |t|
            t.references :project_member, null: false, foreign_key: true
            t.references :role, null: false, foreign_key: true

            t.timestamps
        end

        add_index :project_member_roles, [ :project_member_id, :role_id ], unique: true, name: "project_member_roles_table"
    end
end
