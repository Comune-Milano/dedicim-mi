class AddColumnToTable < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :codice_fiscale, :string, limit: 25
    add_column :decidim_users, :officialized_until, :datetime
    add_column :decidim_users, :form_inviato, :boolean, default: false, null: false
  end
end
