class InsertPostWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(args)
    check_user = User.find_by_name(args["user"]["name"])
    unless check_user
      check_user = User.create!(name: args["user"]["name"], avatar: args["user"]["avatar"])
    end

    check_post = Post.find_by_epoch(args["epoch"])

    if check_post
      # try to update replies
      args["replies"].each do |r|
        reply_user = User.find_by_name(r["name"])
        unless reply_user
          reply_user = User.create!(name: r["name"], avatar: r["avatar"])
        end

        # ui sometimes returns random epoch
        unless check_post.replies.find_by_epoch(r["epoch"])
          unless check_post.replies.find_by(user_id: reply_user.id, reply: r["reply"])
            check_post.replies.create!(user_id: reply_user.id, reply: r["reply"], date: r["date"], epoch: r["epoch"])
          end
        end
      end

      # try to update images
      args["images"].each do |i|
        unless check_post.images.find_by_source(i)
          new_post.images.create!(source: i)
        end
      end
    else
      # create new post
      new_post = Post.create!(
        title: args["title"],
        sub_title: args["sub_title"],
        content_type: args["content_type"],
        content: args["content"],
        date: args["date"],
        epoch: args["epoch"],
        user_id: check_user.id
      )

      # add images to post
      args["images"].each do |i|
        new_post.images.create!(source: i)
      end

      # add replies
      args["replies"].each do |r|
        reply_user = User.find_by_name(r["name"])
        unless reply_user
          reply_user = User.create!(name: r["name"], avatar: r["avatar"])
        end

        new_post.replies.create!(user_id: reply_user.id, reply: r["reply"], date: r["date"], epoch: r["epoch"])
      end 
    end

  end
end