class NotificationMailer < ApplicationMailer

  def new_post
    @user = params[:user]
    @post = params[:post]
    mail(to: @user.email, subject: "New Post: #{@post.title[0, 45]}")
  end

end
