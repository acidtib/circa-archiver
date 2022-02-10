class PostNotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(post_id)
    post = Post.find(post_id)

    users = User.where.not(email: nil)

    users.each do |u|
      NotificationMailer.with(user: u, post: post).new_post.deliver_later
    end
  end
end