class Gameplayers < ActiveRecord::Migration[5.1]
  def change
    create_table :gameplayers do |t|
      t.string :team, null: false
      t.belongs_to :user
      t.belongs_to :game
      t.string :winner, default: ""
    end
  end
end
