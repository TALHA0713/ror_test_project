class Comment < ApplicationRecord
  belongs_to :ticket
  belongs_to :user

  has_many :attachments, dependent: :destroy

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      ticket_id
      user_id
      comment
      created_at
      updated_at
      id_value
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      ticket
      user
      attachments
    ]
  end

  validates :comment, presence: true
end
