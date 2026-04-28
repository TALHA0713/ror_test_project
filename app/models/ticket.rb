class Ticket < ApplicationRecord
  belongs_to :project

  belongs_to :created_by_user,
             class_name: "User"

  belongs_to :assigned_to_user,
             class_name: "User",
             optional: true

  has_many :comments, dependent: :destroy
  has_many :attachments, dependent: :destroy

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
  validates :ticket_no, presence: true, uniqueness: { scope: :project_id }
  validates :ticket_type, presence: true
  validates :status, presence: true
  validates :priority, presence: true
end
