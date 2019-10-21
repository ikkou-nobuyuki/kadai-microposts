class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts
  
  # フォロー機能の実装
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  # お気に入り機能の実装
  has_many :favorites
  has_many :likes, through: :favorites, source: :micropost
  
  # フォローする
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  # フォローを外す
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  # フォロー判定
  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  # お気に入り登録
  def like(micropost)
    favorites.find_or_create_by(micropost_id: micropost.id)
  end
  
  # お気に入りから外す
  def unlike(micropost)
    favorate = favorites.find_by(micropost_id: micropost.id)
    favorate.destroy if favorate
  end
  
  #　お気に入り判定
  def likes?(micropost)
    self.likes.include?(micropost)
  end
end
