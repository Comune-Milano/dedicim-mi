# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing the Assembly' Components in the
      # admin panel.
      #
      class ComponentsController < Decidim::Admin::ComponentsController
       #skip_before_action :verify_authenticity_token
       include Concerns::AssemblyAdmin
      end
    end
  end
end
