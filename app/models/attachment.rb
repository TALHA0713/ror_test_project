class Attachment < ApplicationRecord
  belongs_to :ticket, optional: true
  belongs_to :comment, optional: true

  belongs_to :uploaded_by_user,
             class_name: "User"

  validates :file_name, presence: true
  validates :file_path, presence: true
end
