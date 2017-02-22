class CreateEngagements < ActiveRecord::Migration[5.0]
  def change
    create_table :engagements do |t|
      t.string :type
      t.datetime :timestamp

      t.timestamps
    end
  end
end
