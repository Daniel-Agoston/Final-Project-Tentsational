class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :items
  has_many :bookings
  has_many :reviews, dependent: :destroy

  # Method to check if the user is an admin
  def admin?
    admin
  end
end
