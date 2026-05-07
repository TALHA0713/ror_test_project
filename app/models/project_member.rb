class ProjectMember < ApplicationRecord
  belongs_to :project
  belongs_to :user
  accepts_nested_attributes_for :user
  validates :user_id, uniqueness: { scope: :project_id }

  after_create :on_added_to_project
  after_destroy :on_removed_from_project

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      project_id
      user_id
      is_active
      joined_at
      created_at
      updated_at
      id_value
    ]
  end

  private
  def on_added_to_project
    user.update!(
      project_state_note: "Joined project #{project.name} at #{Time.current}"
    )
  end

  def on_removed_from_project
    debugger
    user.update!(
      project_state_note: "Left project #{project.name} at #{Time.current}",
      updated_at: Time.current
    )
  end
end
