# frozen_string_literal: true
module Decidim
  # A command with all the business logic to create a user from omniauth
  class CreateOmniauthRegistration < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params
    require 'savon'

    def initialize(form, verified_email = nil)
      @form = form
      @verified_email = verified_email
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
     if(form.codice_fiscale)
       verify_oauth_signature!
       realm = Rails.configuration.token_autenticazione_servizi # token ws Anagrafe
	  individuo = ApplicationController.wsanagrafe( form.codice_fiscale,realm )
#	  Rails::logger.warn "*** BEGIN WS ANAGRAFE FABRIZIO***" + individuo.body.to_json + realm + " " + form.codice_fiscale
          if(individuo)
            matricola =  individuo.body.to_hash[:get_ricerca_individui_xml_response][:get_ricerca_individui_xml_result][:lista_individui][:matricola].to_s
	   @residente = ApplicationController.wsresidenza?(form.codice_fiscale,matricola,realm)
            Rails::logger.warn "*** BEGIN WS ANAGRAFE ***"
            Rails::logger.warn "MATRICOLA: #{matricola}"
            Rails::logger.warn "RESIDENTE: #{@residente}"
           # Rails::logger.warn "MAIL: #{mail}"
           # Rails::logger.warn "NAME: #{name}"
           # Rails::logger.warn "SURNAME: #{surname}"
            Rails::logger.warn "*** END WS ANAGRAFE ***"
        end
      begin

        if existing_identity
          user = existing_identity.user
	  verify_sign_in_count(user)
          #verify_user_confirmed(user)
	  verify_user_residenza(user)

          return broadcast(:ok, user)
        end
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_or_find_user
          @identity = create_identity
        end
        trigger_omniauth_registration

        broadcast(:ok, @user)
      rescue ActiveRecord::RecordInvalid => e
        broadcast(:error, e.record)
      end
     else
	     redirect_to '/login_error' #:controller => 'login_error',:action => 'show' # "/decidim/login_error"
            # return render :file => "app/views/decidim/login_error/index.html.erb"
     end
    end

    private

    attr_reader :form, :verified_email

    def create_or_find_user
      generated_password = SecureRandom.hex 
      @user = User.find_or_initialize_by(
       # email: verified_email,
	codice_fiscale: form.codice_fiscale,
        organization: organization
      )
         if (@residente == true)
           confirmed = Time.current
           confirmed_as = {'ca': '','en': '','es': '','it': ''}
         else
           confirmed =  nil
           confirmed_as = nil
         end
      if form.email.to_s == 'testazure@testazure.com'
	mail = form.codice_fiscale + '@testazure.com'
      else
	mail = form.email
      end
      if @user.persisted?
        # If user has left the account unconfirmed and later on decides to sign
        # in with omniauth with an already verified account, the account needs
        # to be marked confirmed.
        @user.skip_confirmation! #if !@user.confirmed? && @user.email == verified_email
      else
	
        @user.email = mail #(verified_email || form.email)
        @user.name = form.name + " " + form.nickname #form.name
       # @user.name = form.name + " " + form.sn #form.name
	@user.nickname = form.normalized_nickname
        @user.newsletter_notifications_at = nil
        @user.email_on_notification = true
	@user.confirmed_at = Time.current
	@user.created_at = Time.current
	@user.officialized_at = confirmed
	@user.officialized_as = confirmed_as
	@user.locale = I18n.default_locale
        @user.password = generated_password
        @user.password_confirmation = generated_password
        @user.remote_avatar_url = form.avatar_url if form.avatar_url.present?
        #@user.skip_confirmation! #if verified_email
	@user.codice_fiscale = form.codice_fiscale
	@user.giuridica_fisica = form.giuridica_fisica
	@user.first_name = form.nome_proprio
	@user.tos_agreement = true
	@user.accepted_tos_version = Time.current
      end

      @user.tos_agreement = true
      @user.accepted_tos_version = Time.current
      @user.save!
    end

    def create_identity
      @user.identities.create!(
        provider: form.provider,
       # uid: form.uid,
	uid: form.codice_fiscale,
        organization: organization
      )
    end

    def organization
      @form.current_organization
    end

    def existing_identity
      @existing_identity ||= Identity.find_by(
        user: organization.users,
        provider: form.provider,
        uid: form.codice_fiscale
      )
    end

    def existing_user
      @existing_identity ||= Identity.find_by(
        user: organization.users,
        provider: form.provider,
        uid: form.uid
      )
    end

    def verify_user_confirmed(user)
      return true if user.confirmed?
      return false if user.email != verified_email

      user.skip_confirmation!
      user.save!
    end
    
    def verify_user_residenza(user)
      if(@residente)
		user.officialized_at = DateTime.now
        user.officialized_until = nil
      else
             now = Time.now.utc
			if user.officialized_until.nil? || now > user.officialized_until
               Rails.logger.info "Il periodo è scaduto!"
               user.officialized_at = nil
               user.officialized_as = nil
               user.officialized_until = nil
               user.form_inviato = false
               Rails.logger.info "L'utente è stato aggiornato!"
          end      
      end

      user.save!
      return true
    end

    def verify_sign_in_count(user)
      if form.email.to_s == 'testazure@testazure.com'
        mail = form.codice_fiscale + '@testazure.com'
      else
        mail = form.email
      end
      if user.sign_in_count.to_s == '1'
       user.skip_confirmation!
       user.skip_reconfirmation!
       user.email = mail
       user.name = form.name + " " + form.nickname
       user.nickname = form.normalized_nickname
       user.save!
      end
      

    end

    def verify_oauth_signature!
      raise InvalidOauthSignature, "Invalid oauth signature: #{form.oauth_signature}" unless signature_valid?
    end

    def signature_valid?
      signature = OmniauthRegistrationForm.create_signature(form.provider, form.uid)
      form.oauth_signature == signature
    end

    def trigger_omniauth_registration
      ActiveSupport::Notifications.publish(
        "decidim.user.omniauth_registration",
        user_id: @user.id,
        identity_id: @identity.id,
        provider: form.provider,
        uid: form.uid,
        email: form.email,
        name: form.name,
	nickname: form.normalized_nickname,
        avatar_url: form.avatar_url,
	codice_fiscale: form.codice_fiscale,
	giuridica_fisica: form.giuridica_fisica,
	nome_proprio: form.nome_proprio,
        raw_data: form.raw_data
      )
    end
  end

  class InvalidOauthSignature < StandardError
  end
end
