# frozen_string_literal: true

module Decidim
  module System
    module Devise
      # Custom Sessions controller for Devise in order to use a custom layout
      # and views.
      class SessionsController < ::Devise::SessionsController
	      # fabrizio
	     #skip_before_action :verify_authenticity_token
        include Decidim::LocaleSwitcher
        helper Decidim::DecidimFormHelper

        layout "decidim/system/login"

        private

        def current_organization; end
      end
    end
  end
end
