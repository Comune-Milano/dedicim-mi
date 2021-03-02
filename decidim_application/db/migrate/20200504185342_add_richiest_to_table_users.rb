class AddRichiestToTableUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :richiesta_at, :datetime	  
  end
end
