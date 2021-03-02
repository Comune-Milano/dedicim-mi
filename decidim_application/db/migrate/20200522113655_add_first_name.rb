class AddFirstName < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :first_name, :string
  end
end
