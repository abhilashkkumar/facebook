class ResultsController < ApplicationController
  def index

  end

  def point1
    $users_freq = Engagement.create_freq_result(date_format(params[:start_date]), date_format(params[:end_date]))
    @only_once = find_n_count($users_freq, 1)
    @more_than_once = find_more_than_n_count($users_freq, 1)
    @bounce_rate = (@only_once.to_f/(@more_than_once+@only_once)).round(3)*100 rescue 0.000
  end

  def point2
  	selected_user = find_n_count($users_freq, params[:repeat_number].to_i)
  	total_user = find_more_than_n_count($users_freq, 0)
  	@percentage = (selected_user.to_f/total_user).round(3)*100 rescue 0.000
  end

  def point3
  	@month_freq = Engagement.month_freq_result(date_format(params[:start_date]), date_format(params[:end_date]))
  	@user_every_month = Engagement.user_present_in_every_month(@month_freq)
    @view_each_month = Engagement.views_each_month(@user_every_month, date_format(params[:start_date]), date_format(params[:end_date]))
    @no_of_likes = Engagement.filter_engagement(date_format(params[:start_date]),date_format(params[:end_date])).where("object_type = ? and user_id in (?)", "like",@user_every_month).count
  end

  protected

  def date_format(date)
  	split_date = date.split("/")
  	DateTime.new(split_date[2].to_i,split_date[0].to_i, split_date[1].to_i)
  end

  def find_more_than_n_count(users_freq_hash, n)
    sum=0
    users_freq_hash.each do |key, value|
      if key > n
        sum+=value.count
      end
    end
    sum
  end

  def find_n_count(users_freq_hash, n)
    users_freq_hash[n].count rescue 0
  end
end
