class ProjectMemberRole < ApplicationRecord
  belongs_to :project_member
  belongs_to :role

  validates :role_id, uniqueness: { scope: :project_member_id }
end
