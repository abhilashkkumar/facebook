class Engagement < ApplicationRecord
  belongs_to :post
  belongs_to :user

  scope :likes, ->{where("object_type = ?", "like")}
  scope :comments, ->{where("object_type = ?", "comment")}

  def self.create_freq_result(start_date, end_date)
    results = filter_engagement(start_date,end_date).group_by{ |t| t.user_id }.group_by{|key, value| value.count}.map{|key,value| {key => value.map{|array| array[0]}}}
    freq_hash = Hash.new
    results.each do |result|
      result.each do |key, value|
        freq_hash[key] = value
      end
    end
    freq_hash
  end

  def self.month_freq_result(start_date, end_date)
    new_start_date = DateTime.new(start_date.year.to_i, start_date.month.to_i, 1)
    new_end_date = DateTime.new(end_date.year.to_i, end_date.month.to_i, 1)
    month_freq = Hash.new
    while new_start_date <= new_end_date
      month_freq["#{new_start_date}-#{new_start_date+1.month}"] = create_freq_result(new_start_date, new_start_date+1.month)
      new_start_date = new_start_date + 1.month
    end
    month_freq
  end

  def self.user_present_in_every_month(month_freq)
    result = nil
    month_freq.each do |key, value|
      value.each do |f,u|
        if result.present?
          result = result & u
        else
          result = u
        end
        break
      end
    end
    result
  end

  def self.views_each_month(users, start_date, end_date)
    new_start_date = DateTime.new(start_date.year.to_i, start_date.month.to_i, 1)
    new_end_date = DateTime.new(end_date.year.to_i, end_date.month.to_i, 1)
    each_month = Hash.new
    while new_start_date <= new_end_date
      each_month["#{new_start_date}-#{new_start_date+1.month}"] = filter_engagement(start_date, end_date).where("user_id in (?)", users).count rescue 0
      new_start_date = new_start_date + 1.month
    end
    each_month
  end

  def self.filter_engagement(start_date, end_date)
    Engagement.where("timestamp >=? and timestamp<=?", start_date, end_date)
  end
end
