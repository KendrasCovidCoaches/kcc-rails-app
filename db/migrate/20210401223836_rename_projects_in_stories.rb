class RenameProjectsInStories < ActiveRecord::Migration[6.0]
  def change
    rename_column(:success_stories, :project_ids, :appointment_ids)
  end
end
