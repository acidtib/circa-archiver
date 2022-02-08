class Post < ApplicationRecord
  belongs_to :user
  has_many :images
  has_many :replies
end

# == Schema Information
#
# Table name: posts
#
#  id           :integer          not null, primary key
#  title        :string
#  sub_title    :string
#  content      :text
#  content_type :string
#  date         :string
#  epoch        :string
#  user_id      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_posts_on_user_id  (user_id)
#
