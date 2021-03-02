class AddColumeBodyRichiestaToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :body_richiesta, :text	  
  end
end
