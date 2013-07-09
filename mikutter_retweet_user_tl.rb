#-*- coding: utf-8 -*-

# 自分のツイートをRTしたユーザのその後5分間ツイートを監視

Plugin.create :retweet_user_tl do
  @retweet_users = {}

  tab(:retweet_user_tl, "自分のツイートをRTしたユーザ") do
    set_icon File.expand_path(File.join(File.dirname(__FILE__), 'icon.png'))
    timeline :retweet_user_tl
  end

  on_retweet do |retweets|
    retweets.each do |message|
      @retweet_users[message.user.idname.to_sym] = Time.now
    end
  end

  on_appear do |messages|
    messages.each do |message|
      timeline(:retweet_user_tl) << message if @retweet_users[message.user.idname.to_sym]
    end
  end

  on_period do
    @retweet_users.each do |idname, time|
      (Service.primary.twitter/'statuses/user_timeline').json(:screen_name => idname.to_s)
    end
    @retweet_users.delete_if do |idname, time|
      Time.now - time >= 600
    end
  end
  
end

