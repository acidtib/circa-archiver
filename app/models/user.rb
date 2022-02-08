class User < ApplicationRecord
  has_many :posts
  has_many :replies
end

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string
#  avatar     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
