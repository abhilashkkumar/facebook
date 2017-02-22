class RenameColumnFromEngagement < ActiveRecord::Migration[5.0]
  def change
  	rename_column :engagements, :type, :object_type
  end
end
