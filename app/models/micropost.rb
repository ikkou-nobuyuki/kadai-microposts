class Micropost < ApplicationRecord
  belongs_to :user
  
  validates :content, presence: true, length: { maximum: 255 }
  
  # お気に入り機能の実装
  has_many :favorites
  has_many :be_liked, through: :favorites, source: :user
end
