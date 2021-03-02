# frozen_string_literal: true

module Decidim
  # The controller to show all the last activities in a Decidim Organization.
  class UserActivitiesController < Decidim::ApplicationController
    include Paginable
    include UserGroups

    helper Decidim::ResourceHelper
    helper_method :activities, :user

    def index
      if current_user != nil && (current_user.admin? || current_user.nickname == params[:nickname])
      else
	redirect_to root_path
      end	    
    end

    private

    def user
      @user ||= current_organization.users.find_by(nickname: params[:nickname])
    end

    def activities
      @activities ||= paginate(
        ActivitySearch.new(
          organization: current_organization,
          user: user,
          resource_type: "all"
        ).run
      )
    end
  end
end
