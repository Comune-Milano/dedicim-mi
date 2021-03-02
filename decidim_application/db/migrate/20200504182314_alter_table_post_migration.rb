class AlterTablePostMigration < ActiveRecord::Migration[5.2]
  def change
    execute "alter table decidim_components
    add testo_originale boolean default false not null;"
    execute "comment on column decidim_users.codice_fiscale is 'Il codice fiscale dell''utente';"
    execute "comment on column decidim_users.form_inviato is 'La richiesta di partecipare';"	  
  end
end
