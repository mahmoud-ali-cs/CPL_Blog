# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  validates_presence_of :body, :title


  def all_tags=(names)
    self.tags = names.split(",").map do |name|
        Tag.where(name: name.strip.downcase).first_or_create!
    end
  end
  
  def all_tags
    self.tags.map(&:name).join(", ")
  end

end
