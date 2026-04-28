class CreateAttachments < ActiveRecord::Migration[8.1]
    def change
         create_table :attachments do |t|
            t.references :ticket, null: true, foreign_key: true
            t.references :comment, null: true, foreign_key: true
            t.references :uploaded_by_user, null: false, foreign_key: { to_table: :users }

            t.string :file_name, null: false
            t.string :file_path, null: false
            t.string :mime_type
            t.bigint :file_size

            t.timestamps
        end

        add_check_constraint :attachments,
                           "(ticket_id IS NOT NULL AND comment_id IS NULL) OR (ticket_id IS NULL AND comment_id IS NOT NULL)",
                           name: "attachments_ticket"
    end
end
