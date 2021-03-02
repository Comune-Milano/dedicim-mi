# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # This controller allows exporting things.
      # It is targeted for customizations for exporting things that lives under
      # a participatory process.
      class ExportsController < Decidim::Admin::ExportsController
        include Concerns::ParticipatoryProcessAdmin
        #skip_before_action :verify_authenticity_token
      end
    end
  end
end
