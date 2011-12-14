class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.references :user
      t.boolean :shared
      t.string :search    
      t.string :nodes_list
      t.string  :slug

      t.timestamps
    end
    add_index :groups, :slug, :unique => true
  end
end
