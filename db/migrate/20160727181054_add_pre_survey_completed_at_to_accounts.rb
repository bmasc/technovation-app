class AddPreSurveyCompletedAtToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :pre_survey_completed_at, :datetime
  end
end
