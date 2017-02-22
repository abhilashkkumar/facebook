class AddUserAndPostToEngagement < ActiveRecord::Migration[5.0]
  def change
    add_reference :engagements, :user, index: true
    add_reference :engagements, :post, index: true
  end
end
