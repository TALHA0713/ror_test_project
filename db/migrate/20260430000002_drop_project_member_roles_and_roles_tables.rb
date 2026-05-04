class DropProjectMemberRolesAndRolesTables < ActiveRecord::Migration[8.1]
  def up
    drop_table :project_member_roles
    drop_table :roles
  end
end
