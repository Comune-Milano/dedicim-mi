# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing categories for participatory processes.
      #
      class CategoriesController < Decidim::Admin::CategoriesController
       #skip_before_action :verify_authenticity_token
	include Concerns::ParticipatoryProcessAdmin
      end
    end
  end
end
