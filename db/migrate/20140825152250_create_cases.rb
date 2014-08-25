class CreateCases < ActiveRecord::Migration
  def change
    create_table :cases do |t|
      t.string :file

      t.timestamps
    end
  end
end
