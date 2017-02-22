module InitializeSite

  def self.initialize
    next_posts = InitializeSite.next("https://graph.facebook.com/channel42india/posts?access_token=#{User::ACCESS_TOKEN}")
    begin
      next_posts["data"].each do |post|

        new_post = Post.new(:post_id => post["id"], :timestamp => post["created_time"])
        new_post.save

        InitializeSite.count_likes(new_post.post_id)
        InitializeSite.count_comments(new_post.post_id)

      end

      if next_posts["paging"].present?
        error
      end

    rescue Exception => e
      next_posts = InitializeSite.next(next_posts["paging"]["next"]) rescue nil
      if next_posts.present?
        retry
      end
    end
  end


  def self.count_likes(post_id)

    post = Post.find_by_post_id(post_id)
    likes = InitializeSite.next("https://graph.facebook.com/#{post_id}/likes?access_token=#{User::ACCESS_TOKEN}")
    begin
      likes["data"].each do |like|
        user = User.find_by_user_id(like["id"])
        if user.present?
          Engagement.new(:user_id => user.id, :post_id => post.id, :timestamp => post.timestamp, :object_type => "like").save
        else
          new_user = User.new(:user_id => like["id"])
          new_user.save
          Engagement.new(:user_id => new_user.id, :post_id => post.id, :timestamp => post.timestamp, :object_type => "like").save
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


  def self.count_comments(post_id)
    post = Post.find_by_post_id(post_id)
    comments = InitializeSite.next("https://graph.facebook.com/#{post_id}/comments?access_token=#{User::ACCESS_TOKEN}")
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

  def self.next(url)
    if url.blank?
      return url
    end

    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri

      response = http.request request
      return JSON.parse(response.body)
    end

  end

end
