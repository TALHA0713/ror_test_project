class ProjectMember < ApplicationRecord
  belongs_to :project
  belongs_to :user

  has_many :project_member_roles, dependent: :destroy
  has_many :roles, through: :project_member_roles

  validates :user_id, uniqueness: { scope: :project_id }
end
