class PostsController < ApplicationController
 
  def index
    posts = Post.unscoped.includes(:user, :images, replies: [:user]).order("epoch DESC").page(params[:page]).per(10)
    
    result = posts.each.map do |post|
      {
        id: post.id,
        title: post.title,
        sub_title: post.sub_title,
        content_type: post.content_type,
        date: post.date,
        epoch: post.epoch,
        content: post.content,
        user: {
          id: post.user.id,
          name: post.user.name,
          avatar: post.user.avatar
        },
        images: post.images.map { |im| {id: im.id, source: im.source} },
        replies: post.replies.order("epoch DESC").map { |re| {
          id: re.id, 
          date: re.date, 
          epoch: re.epoch, 
          reply: re.reply, 
          user: {id: re.user.id, name: re.user.name, avatar: re.user.avatar}
        } }
      }
    end

    payload = { 
      data: result, 
      meta: response_meta(posts)
    }

    render json: payload
  end

  def show
    post = Post.includes(:user, :images, replies: [:user]).find(params[:post_id])

    result = {
      id: post.id,
      title: post.title,
      sub_title: post.sub_title,
      content_type: post.content_type,
      date: post.date,
      epoch: post.epoch,
      content: post.content,
      user: {
        id: post.user.id,
        name: post.user.name,
        avatar: post.user.avatar
      },
      images: post.images.map { |im| {id: im.id, source: im.source} },
      replies: post.replies.order("epoch DESC").map { |re| {
        id: re.id, 
        date: re.date, 
        epoch: re.epoch, 
        reply: re.reply, 
        user: {id: re.user.id, name: re.user.name, avatar: re.user.avatar}
      } }
    }

    payload = { 
      data: result
    }

    render json: payload
  end
end
