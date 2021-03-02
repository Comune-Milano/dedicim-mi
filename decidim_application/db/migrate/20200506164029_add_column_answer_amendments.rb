class AddColumnAnswerAmendments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_amendments, :answer, :string	  
  end
end
