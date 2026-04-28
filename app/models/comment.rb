class Comment < ApplicationRecord
  belongs_to :ticket
  belongs_to :user

  has_many :attachments, dependent: :destroy

  validates :comment, presence: true
end
