class ModifyIndexNickname < ActiveRecord::Migration[5.2]
  def change
    execute "DROP INDEX public.index_decidim_users_on_nickame_and_decidim_organization_id;"
  end
end
