class Account < ApplicationRecord
  validates :provider, presence: true
  validates :uid, presence: true

  def self.from_omniauth(auth_hash, current_user)
    current_user.accounts.find_or_create_by(
      uid: auth_hash[:uid],
      provider: auth_hash[:provider]
    )
  end
end
