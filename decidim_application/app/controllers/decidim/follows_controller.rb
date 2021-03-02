# frozen_string_literal: true

module Decidim
  class FollowsController < Decidim::ApplicationController
    include FormFactory
    include Decidim::UserProfile
    before_action :authenticate_user!
    helper_method :resource
   # skip_before_action :verify_authenticity_token
    def destroy
      @form = form(Decidim::FollowForm).from_params(params)
      @inline = params[:follow][:inline] == "true"
      enforce_permission_to :delete, :follow, follow: @form.follow

      DeleteFollow.call(@form, current_user) do
        on(:ok) do
          render :update_button
        end

        on(:invalid) do
          render json: { error: I18n.t("follows.destroy.error", scope: "decidim") }, status: :unprocessable_entity
        end
      end
    end

    def create
      if !current_user.admin? && current_user.form_partecipazione_inviato? && !current_user.officialized?
        render :show_modal2
      else
	if current_user.admin? || current_user.officialized?
          @form = form(Decidim::FollowForm).from_params(params)
          @inline = params[:follow][:inline] == "true"
          enforce_permission_to :create, :follow

          CreateFollow.call(@form, current_user) do
            on(:ok) do
              render :update_button
            end

            on(:invalid) do
              render json: { error: I18n.t("follows.create.error", scope: "decidim") }, status: :unprocessable_entity
            end
          end
        else
          render :show_modal
        end
      end
    end

    def resource
      @resource ||= GlobalID::Locator.locate_signed(
        params[:follow][:followable_gid]
      )
    end
  end
end

