class Account < ApplicationRecord
  validates :provider, presence: true
  validates :uid, presence: true

  def self.from_omniauth(auth_hash)
    account = self.find_or_create_by(uid: auth_hash['uid'], provider: auth_hash['provider'], user_id)
    account.name =
  end
end
