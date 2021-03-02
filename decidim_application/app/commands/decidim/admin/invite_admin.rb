# frozen_string_literal: true

module Decidim
  module Admin
    # A command to invite an admin.
    class InviteAdmin < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?
        generated_password = SecureRandom.hex
        @name = params[:user][:name]
        @nickname = @name.parameterize
        @email = params[:user][:email]
        @cf = params['codice_fiscale']
        @role = params[:user][:role]
        logger.warn "BEGIN"
        logger.warn @name
        logger.warn @email
        logger.warn @role
        logger.warn "END"
        @user = Decidim::User.new()
        @user.name = @name
        @user.nickname = @nickname.downcase
        @user.decidim_organization_id = current_user.decidim_organization_id
        @user.email = @email
        @user.newsletter_notifications_at = nil
        @user.email_on_notification = true
        @user.password = generated_password
        @user.password_confirmation = generated_password
        @user.skip_confirmation!
        @user.officialized_at = DateTime.now
        @user.codice_fiscale = @cf
        @user.tos_agreement = "1"
        if @role == 'admin'
          @user.admin = true
        elsif @role == 'user_manager'
          @user.roles = '{user_manager}'
        end
        @user.save!
        #transaction do
        #  invite_user
        #  log_action
        #end

        broadcast(:ok)

      end

      private

      attr_reader :user, :form

      def invite_user
        InviteUser.call(form) do
          on(:ok) do |user|
            save_user(user)
          end
        end
      end

      # Ugly fix to get the user from the block inside the
      # `InviteUser#call` method. I'm not proud of this.
      def save_user(user)
        @user = user
      end

      def log_action
        Decidim.traceability.perform_action!(
          "invite",
          user,
          form.current_user,
          extra: {
            invited_user_role: form.role,
            invited_user_id: user.id
          }
        )
      end
    end
  end
end
