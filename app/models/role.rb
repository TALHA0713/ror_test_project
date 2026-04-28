class Role < ApplicationRecord
  has_many :project_member_roles, dependent: :destroy
  has_many :project_members, through: :project_member_roles

  validates :name, presence: true, uniqueness: true
  validates :name, inclusion: { in: %w[manager qa developer] }
end
