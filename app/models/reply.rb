class Reply < ApplicationRecord
  belongs_to :post
  belongs_to :user
end

# == Schema Information
#
# Table name: replies
#
#  id         :integer          not null, primary key
#  post_id    :integer          not null
#  user_id    :integer          not null
#  reply      :text
#  date       :string
#  epoch      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_replies_on_post_id  (post_id)
#  index_replies_on_user_id  (user_id)
#
