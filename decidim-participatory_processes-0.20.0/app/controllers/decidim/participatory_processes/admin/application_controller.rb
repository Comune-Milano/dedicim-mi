# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # The main admin application controller for participatory processes
      class ApplicationController < Decidim::Admin::ApplicationController
        register_permissions(::Decidim::ParticipatoryProcesses::Admin::ApplicationController,
                             ::Decidim::ParticipatoryProcesses::Permissions,
                             ::Decidim::Admin::Permissions)
	#skip_before_action :verify_authenticity_token
        private

        def permissions_context
          super.merge(
            current_participatory_space: try(:current_participatory_space)
          )
        end

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::ParticipatoryProcesses::Admin::ApplicationController)
        end
      end
    end
  end
end
