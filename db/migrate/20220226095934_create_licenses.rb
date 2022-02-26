class CreateLicenses < ActiveRecord::Migration[7.0]
  def change
    create_table :licenses do |t|
      t.date :paid_till, null: false
      t.string :min_version
      t.string :max_version

      t.timestamps
    end
  end
end
