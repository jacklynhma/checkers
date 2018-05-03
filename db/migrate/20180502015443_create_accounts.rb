class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :provider, null: false
      t.string :uid, null: false
      t.belongs_to :user
    end
  end
end
