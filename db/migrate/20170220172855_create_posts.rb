class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string :post_id
      t.datetime :timestamp

      t.timestamps
    end
  end
end
