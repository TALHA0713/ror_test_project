class Ticket < ApplicationRecord
  belongs_to :project

  belongs_to :created_by_user,
             class_name: "User"

  belongs_to :assigned_to_user,
             class_name: "User",
             optional: true

  has_many :comments, dependent: :destroy
  has_many :attachments, dependent: :destroy

  before_validation :assign_ticket_no, on: :create
  before_save :set_closed_at_value

  enum :ticket_type, {
    bug: "bug",
    feature: "feature",
    task: "task"
  }

  enum :status, {
    open: "open",
    in_progress: "in_progress",
    resolved: "resolved",
    closed: "closed"
  }

  enum :priority, {
    low: "low",
    medium: "medium",
    high: "high",
    urgent: "urgent"
  }

  validates :title, presence: true
  validates :project_id, presence: true
  validates :ticket_no, presence: true, uniqueness: { scope: :project_id }
  validates :ticket_type, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :assigned_to_user_id, presence: true

  validate :assigned_user_must_belong_to_project

  scope :ordered, -> { includes(:project, :created_by_user, :assigned_to_user).order(updated_at: :desc) }

  def ticket_label
    "##{ticket_no}"
  end

  private

  def assign_ticket_no
    return if ticket_no.present? || project.blank?

    self.ticket_no = project.next_ticket_no
  end

  def set_closed_at_value
    self.closed_at = closed? ? (closed_at || Time.current) : nil
  end

  def assigned_user_must_belong_to_project
    return if assigned_to_user_id.blank? || project.blank?
    return if project.active_members.where(user_id: assigned_to_user_id).exists?

    errors.add(:assigned_to_user_id, "must belong to the selected project")
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      project_id
      assigned_to_user_id
      created_by_user_id
      title
      description
      ticket_no
      ticket_type
      priority
      status
      due_date
      closed_at
      created_at
      updated_at
      id_value
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      project
      created_by_user
      assigned_to_user
      comments
      attachments
    ]
  end
end
