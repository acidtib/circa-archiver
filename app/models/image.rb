class Image < ApplicationRecord
  belongs_to :post
end

# == Schema Information
#
# Table name: images
#
#  id         :integer          not null, primary key
#  source     :string
#  post_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_images_on_post_id  (post_id)
#
