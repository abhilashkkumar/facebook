module FacebookJob

  def self.update_database
    last_post_timestamp = Post.order('timestamp desc').first.timestamp.to_i + 1
    post_ids = Post.where("timestamp >= ? and timestamp <= ?", DateTime.now - 2.days, DateTime.now).order('timestamp desc').pluck(:post_id)
    post_ids.each do |post_id|
      FacebookJob.count_likes(post_id)
      FacebookJob.count_comments(post_id, nil)
    end
    new_posts = InitializeSite.next("https://graph.facebook.com/channel42india/posts?access_token=#{User::ACCESS_TOKEN}&since=#{last_post_timestamp}")
    begin
      new_posts["data"].each do |new_post|

        post = Post.new(:post_id => new_post["id"], :timestamp => new_post["created_time"])
        post.save
        FacebookJob.count_likes(post.post_id)
        FacebookJob.count_comments(post.post_id, nil)
      end

      if new_posts["paging"].present?
        error
      end

    rescue Exception => e
      new_posts = InitializeSite.next(next_posts["paging"]["next"]) rescue nil
      if new_posts.present?
        retry
      end
    end
  end

  def self.count_likes(post_id)
    post = Post.find_by_post_id(post_id)
    likes = InitializeSite.next("https://graph.facebook.com/#{post_id}/likes?access_token=#{User::ACCESS_TOKEN}")
    users_already_liked = post.likes.pluck(:user_id)
    begin
      likes["data"].each do |like|
        user = users.find_by_user_id(like["id"])
        if user.present?
          unless (users_already_liked.include? user.id)
            Engagement.new(:user_id => user.id, :post_id => post.id, :timestamp => DateTime.now, :object_type => "like").save
          end
        else
          new_user = User.new(:user_id => like["id"])
          new_user.save
          Engagement.new(:user_id => new_user.id, :post_id => post.id, :timestamp => DateTime.now, :object_type => "like").save
        end
      end
      if likes["paging"].present?
        error
      end
    rescue Exception => e
      likes = InitializeSite.next(likes["paging"]["next"]) rescue nil
      if likes.present?
        retry
      end
    end
  end

  def self.count_comments(post_id, since)
    post = Post.find_by_post_id(post_id)
    last_comment_timestamp = post.comments.order('timestamp desc').first.timestamp.to_i + 1
    if since.blank?
      comments = InitializeSite.next("https://graph.facebook.com/#{post_id}/comments?access_token=#{User::ACCESS_TOKEN}&since=#{last_comment_timestamp}")
    else
      comments = InitializeSite.next("https://graph.facebook.com/#{post_id}/comments?access_token=#{User::ACCESS_TOKEN}&since=#{since}")
    end
    begin
      comments["data"].each do |comment|
        user = User.find_by_user_id(comment["from"]["id"])
        if user.present?
          Engagement.new(:user_id => user.id, :post_id => post.id, :timestamp => comment["created_time"], :object_type => "comment").save
        else
          new_user = User.new(:user_id => comment["from"]["id"])
          new_user.save
          Engagement.new(:user_id => new_user.id, :post_id => post.id, :timestamp => comment["created_time"], :object_type => "comment").save
        end
      end
      if comments["paging"].present?
        error
      end
    rescue Exception => e
      comments = InitializeSite.next(comments["paging"]["next"]) rescue nil
      if comments.present?
        retry
      end
    end
  end

end
