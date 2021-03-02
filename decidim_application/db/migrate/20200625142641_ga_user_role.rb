class GaUserRole < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :ga, :boolean, default: false, null: false
  end
end
