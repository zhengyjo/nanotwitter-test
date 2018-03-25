class CreateMention < ActiveRecord::Migration[5.1]
  def change
    create_table :mentions do |t|
      t.string :username
      t.integer :tweet_id

    end
  end
end
