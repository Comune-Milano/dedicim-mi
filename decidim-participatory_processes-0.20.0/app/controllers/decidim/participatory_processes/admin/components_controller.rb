# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing the Participatory Process' Components in the
      # admin panel.
      #
      class ComponentsController < Decidim::Admin::ComponentsController
	#skip_before_action :verify_authenticity_token
        include Concerns::ParticipatoryProcessAdmin
      end
    end
  end
end
