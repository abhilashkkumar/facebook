class User < ApplicationRecord

  validates_uniqueness_of :user_id

  has_one :like, ->{where("object_type = ?", "like")}, class_name: 'Engagement'
  has_many :comments, -> {where("object_type = ?", "comment")}, class_name: 'Engagement'

  ACCESS_TOKEN = "EAACEdEose0cBACuRpePhdteApJRyNCG2RWLHQ1GTVZB9E7RPZAOiMrOZChgnhITETpWBaPVe1jnGaBlzJu49sa9hISeKQZA9AkHO9l1crDJpfeD1H6z3ZCYyavjmkWLZBcM5gxM8K9B4Sykcn4yj32ntytKFWwghx8s4nT3k0RrcPma23f8HeaJhP91aaJ46xbjHPhgtoPiAZDZD"

end
