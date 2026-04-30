require "fileutils"
require "securerandom"

class Attachment < ApplicationRecord
  belongs_to :ticket, optional: true
  belongs_to :comment, optional: true

  belongs_to :uploaded_by_user,
             class_name: "User"

  validates :file_name, presence: true
  validates :file_path, presence: true

  # Saves uploaded files for a ticket or a comment.
  # `record` can be a Ticket or a Comment (both have has_many :attachments).
  def self.save_files_for(record, files, user)
    return if files.blank?

    folder = record.class.name.downcase.pluralize

    files.each do |uploaded_file|
      next if uploaded_file.blank?

      directory_path = Rails.root.join("public", "uploads", folder, record.id.to_s)
      FileUtils.mkdir_p(directory_path)

      original_name = uploaded_file.original_filename.to_s
      file_extension = File.extname(original_name)
      base_name = File.basename(original_name, file_extension).parameterize(separator: "_")
      base_name = "attachment" if base_name.blank?
      safe_file_name = "#{Time.current.to_i}_#{SecureRandom.hex(4)}_#{base_name}#{file_extension}"
      full_file_path = directory_path.join(safe_file_name)

      File.binwrite(full_file_path, uploaded_file.read)

      record.attachments.create(
        uploaded_by_user: user,
        file_name: uploaded_file.original_filename,
        file_path: "/uploads/#{folder}/#{record.id}/#{safe_file_name}",
        mime_type: uploaded_file.content_type,
        file_size: uploaded_file.size
      )
    end
  end
end
