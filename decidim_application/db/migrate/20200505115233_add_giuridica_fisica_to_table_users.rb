class AddGiuridicaFisicaToTableUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :giuridica_fisica, :string, limit: 2
  end
end
