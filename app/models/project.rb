class Project < ApplicationRecord
  belongs_to :created_by_user,
             class_name: "User"

  has_many :project_members, dependent: :destroy
  has_many :users, through: :project_members
  has_many :tickets, dependent: :destroy

  validates :name, presence: true
end
