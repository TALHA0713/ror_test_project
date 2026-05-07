class Project < ApplicationRecord
  belongs_to :created_by_user,
             class_name: "User"

  has_many :project_members, dependent: :destroy
  has_many :users, through: :project_members
  accepts_nested_attributes_for :project_members
  has_many :tickets, dependent: :destroy

  validates :name, presence: true

  def active_members
    project_members.where(is_active: true)
  end

  def assignable_users
    User.joins(:project_members)
        .where(project_members: { project_id: id, is_active: true })
        .order(:name)
        .distinct
  end

  def next_ticket_no
    (tickets.maximum(:ticket_no) || 0) + 1
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      name
      description
      created_by_user_id
      created_at
      updated_at
      id_value
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      created_by_user
      project_members
      users
      tickets
    ]
  end
end
