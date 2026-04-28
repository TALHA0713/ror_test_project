class CreateTickets < ActiveRecord::Migration[8.1]
    def change
         create_table :tickets do |t|
            t.references :project, null: false, foreign_key: true
            t.integer :ticket_no, null: false

            t.string :title, null: false
            t.text :description
            t.string :ticket_type, null: false

            t.string :status, null: false, default: "open"
            t.string :priority, null: false, default: "medium"

            t.references :created_by_user, null: false, foreign_key: { to_table: :users }
            t.references :assigned_to_user, null: true, foreign_key: { to_table: :users }

            t.date :due_date
            t.datetime :closed_at

            t.timestamps
        end

        add_check_constraint :tickets,
                            "ticket_type IN ('bug', 'feature', 'task')",
                            name: "ticket_type"

        add_check_constraint :tickets,
                            "status IN ('open', 'in_progress', 'resolved', 'closed')",
                            name: "ticket_status"

        add_check_constraint :tickets,
                            "priority IN ('low', 'medium', 'high', 'urgent')",
                            name: "ticket_priority"

        add_index   :tickets,
                    [ :project_id, :ticket_no ],
                    unique: true
    end
end
