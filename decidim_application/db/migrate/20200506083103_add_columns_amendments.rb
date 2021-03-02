class AddColumnsAmendments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_amendments, :answered_at, :datetime, index: true
  end
end
