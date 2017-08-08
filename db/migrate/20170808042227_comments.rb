class Comments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.string :body, null: false
      t.belongs_to :user
      t.belongs_to :game
    end
  end
end
