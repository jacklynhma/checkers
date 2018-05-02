class AddUniqueIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :accounts, :provider
    add_index :accounts, :uid
    add_index :accounts, [:provider, :uid], unique: true
  end
end
