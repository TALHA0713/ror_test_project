class User < ApplicationRecord
  has_secure_password validations: false

  ROLES = %w[manager developer qa].freeze

  has_many :project_members, dependent: :destroy
  has_many :projects, through: :project_members

  has_many :created_projects,
           class_name: "Project",
           foreign_key: :created_by_user_id,
           dependent: :nullify

  has_many :created_tickets,
           class_name: "Ticket",
           foreign_key: :created_by_user_id,
           dependent: :nullify

  has_many :assigned_tickets,
           class_name: "Ticket",
           foreign_key: :assigned_to_user_id,
           dependent: :nullify

  has_many :comments, dependent: :destroy

  has_many :uploaded_attachments,
           class_name: "Attachment",
           foreign_key: :uploaded_by_user_id,
           dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :password, presence: true, length: { minimum: 6 }, confirmation: true, on: :create
  validates :password, length: { minimum: 6 }, allow_blank: true, confirmation: true, on: :update

  def manager?
    role == "manager"
  end

  def active_project_member_for(project)
    project_members.find_by(project: project, is_active: true)
  end
end
