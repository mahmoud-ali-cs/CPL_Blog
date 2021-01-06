# == Schema Information
#
# Table name: followings
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  followed_id :bigint
#  follower_id :bigint
#
# Indexes
#
#  index_followings_on_followed_id  (followed_id)
#  index_followings_on_follower_id  (follower_id)
#
# Foreign Keys
#
#  fk_rails_...  (followed_id => users.id)
#  fk_rails_...  (follower_id => users.id)
#
require 'rails_helper'

RSpec.describe Following, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
