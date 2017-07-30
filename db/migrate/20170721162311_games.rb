class Games < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.string :name, null: false
      t.json :state_of_piece, null: false
      t.json :history_of_pieces, null: false

      t.timestamps
    end
  end
end
