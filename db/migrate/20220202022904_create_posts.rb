class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :sub_title
      t.text :content
      t.string :content_type
      t.string :date
      t.string :epoch
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
