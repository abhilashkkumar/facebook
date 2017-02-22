class Post < ApplicationRecord

  validates_uniqueness_of :post_id

  has_many :likes, ->{where("object_type = ?", "like")}, class_name: 'Engagement'
  has_many :comments, -> {where("object_type = ?", "comment")}, class_name: 'Engagement'

end
