class SsoLoginController < ApplicationController
    #skip_before_action :verify_authenticity_token, only: [:sso_login, :logout]
    require 'net/http'
    require 'net/https'

    def login
	    logger.warn "*** BEGIN RAW REQUEST HEADERS ***"
        self.request.headers.each do |header|
          logger.warn "HEADER KEY: #{header[0]}"
          logger.warn "HEADER VAL: #{header[1]}"
        end
        logger.warn "*** END RAW REQUEST HEADERS ***"
        # @user = Decidim::User.find_by(email: params[:CDM_CF].downcase)
	cf = self.request.headers['HTTP_CDM_CF']
        name = self.request.headers['HTTP_CDM_NAME']
        surname = self.request.headers['HTTP_CDM_SURNAME']
        mail = cf + '@testazure.com' #self.request.headers['HTTP_CDM_MAIL']
        @user = Decidim::User.find_by(codice_fiscale: cf)
        # render :json => @user
        if(@user) # se l'utente esiste lo autentico
            sign_in @user
           #  redirect_to "/decidim"

        else # creo l'utente
        current_organization = Decidim::Organization.first
          regular_user = Decidim::User.find_or_initialize_by(codice_fiscale: cf)
          password = SecureRandom.urlsafe_base64
          regular_user.update!(
            name: name + ' ' + surname,
            email: mail,
            nickname: Decidim::UserBaseEntity.nicknamize(name, organization: current_organization),
            password: password,
            password_confirmation: password,
            confirmed_at: Time.current,
            officialized_at: Time.current,
            officialized_as: {'ca': '','en': '','es': '','it': ''},
            locale: I18n.default_locale,
            organization: current_organization,
            tos_agreement: true,
            #personal_url: Faker::Internet.url,
            #about: Faker::Lorem.paragraph(2),
            accepted_tos_version: current_organization.tos_version,
            codice_fiscale: cf
          )
            sign_in regular_user
        end
          # redirect_to "/"
        
        # session[:user] = @user.id
        redirect_to "www.google.com"        
        
    end

    def pippo
	    logger.warn "*** BEGIN RAW REQUEST HEADERS ***"
	self.request.headers.each do |header|
	  logger.warn "HEADER KEY: #{header[0]}"
	  logger.warn "HEADER VAL: #{header[1]}"
	end
	logger.warn "*** END RAW REQUEST HEADERS ***"
	name = self.request.headers['HTTP_CDM_MAIL']
	render :json => name
   	#  request.env.to_hash.select{ |key,val| ! key.starts_with?("rack") && ! key.starts_with?("action_")}
    end

    def debug
    	render :json => params
    end

    def logout
	    #if params[:SAMLRequest]
		#    return idp_logout_request
	    #elsif params[:SAMLResponse]
		#    return process_logout_response
	    #elsif params[:slo]
		#    return sp_logout_request
	    #else
		#    reset_session
	    #end
	    #
	    #
	    #	cf = self.request.headers['HTTP_CDM_CF']
#	@user = Decidim::User.find_by(codice_fiscale: cf)
#	session.delete(key)
	reset_session
      	redirect_to ENV["SERVER_COMUNE"] + 'cdmlogout/Logout.html'
    end

    def cortesia
       # render :file => "app/views/layouts/decidim/courtesy_page.html.erb"
       render 'layouts/decidim/courtesy_page'
    end

    def post
	   # @request_params["SAMLRequest"] = params.to_s.gsub(/\n/, "")
#	settings = Devise.omniauth_configs[:saml].strategy	
      #  params = create_params(settings, params)
    #params_prefix = (settings.idp_sso_target_url =~ /\?/) ? '&' : '?'
	log_1 = params.delete("SAMLRequest")
	#saml_request = Base64.encode64(log_1).gsub(/\n/, "")
	saml_request = log_1.gsub(/\n/, "")
#        saml_request = CGI.unescape(log_1)
	# saml_request = decode(log_1)
	
	 settings = Devise.omniauth_configs[:saml].strategy
	 render 'login_request', locals: {url: settings.idp_sso_target_url, saml_request: saml_request}
#	 
	 #
	 #
	 #	 Rails.logger.info(' ++++++++++++ PARAMS +++++++++++++++++++')
#	 Rails.logger.info(params)
#	 if params['RelayState'] =~ /\/slo$/
#		 url = settings.idp_slo_target_url.to_s
#	 else
#		 url = settings.idp_sso_target_url.to_s
	# end
	#Rails.logger.info(url)	
#	logger.warn "params.delete('SAMLRequest')" + log_1.to_json
#	logger.warn " unescape " + saml_request
#	    saml_request = params.delete("SAMLRequest").gsub('+',' ')
       # request_params = "#{params_prefix}SAMLRequest=#{saml_request}"
       # request_params["SAMLRequest"] = Base64.encode64(@request).gsub(/\n/, "")
        ## str = "<html><body onLoad=\"document.getElementById('form').submit();\">\n"
        # str = "<html><body>\n"
        #str += "<form id='form' name='form' method='POST' action=\"#{url}\">\n"
         ##str += "<form id='form' name='form' method='POST' action='#{settings.idp_sso_target_url}'  >\n"
      #  str += "<input name='RelayState' value='ruby-saml' type='hidden' />\n"
      
      #	params.each_pair do |key, value|
        ## str += "<input name=\"SAMLRequest\" value=\"#{saml_request}\" type=\"hidden\" />\n"
 #	str += "<input name=\"#{key}\" value=\"#{value}\" type='hidden' />\n"
  #      end
	# str += " <input type='submit'> "
        ## str += "</form></body></html>\n"

	#  my_connection = Net::HTTP.new(settings.idp_sso_target_url)
	#reponse = my_connection.post(path_within_url, data)
       # HTTParty.post(settings.idp_sso_target_url, body: { SAMLRequest: saml_request })i
#	uri = URI.parse(settings.idp_sso_target_url)
    #	uri.query = URI.encode_www_form({ SAMLRequest: saml_request })
    #	http = Net::HTTP.new(uri.host, uri.port)
    #	http.use_ssl = true
    #	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #	request = Net::HTTP::Post.new(uri.request_uri)
    #	http.request(request).body
	
	#render inline: str
#	    saml_settings = Devise.omniauth_configs[:saml].strategy
#	saml_request = OneLogin::RubySaml::Authrequest.new
#	post_params = saml_request.create_params(saml_settings, params= {})
#	@login_url   = saml_settings.idp_sso_target_url
#	render inline: saml_request.to_json
    end

    def logout_idp
	Rails.logger.info(' +++++++ LOGOUT EUREKA +++++++ ')
	Rails.logger.info(params.to_json)
	options = Devise.omniauth_configs[:saml].strategy
        settings = OneLogin::RubySaml::Settings.new(options)
	relayState = url_for controller: 'sso_login', action: 'logout' #params['RelayState']
	form_params = {
                        url: settings.idp_slo_target_url,
                        saml_request: params['SAMLResponse'].gsub(/\r\n/, ""),
                        relay_state: relayState
                }
	render 'logout_response', locals: form_params

    end

    def saml_logout
	    Rails.logger.info(' +++++++ LOGOUT +++++++ ')
	    Rails.logger.info(params)
	    relay_state = params['RelayState']
	    saml_request = params['SAMLRequest'].gsub(/\n/, "")
	    
	    
	    settings = Devise.omniauth_configs[:saml].strategy	    
	    #str = "<html><body onLoad=\"document.getElementById('form').submit();\">\n"
	    str = "<html><body>\n"
	    str += "<form id='form' name='form' method='POST' action='#{settings.idp_slo_target_url}'  >\n"
	    
	    
	    str += "<input name=\"SAMLRequest\" value=\"#{saml_request}\" type=\"hidden\" />\n"
	    str += "<input name=\"RelayState\" value=\"#{relay_state}\" type=\"hidden\" />\n"
	    str += " <input type='submit'> "
	    str += "</form></body></html>\n"
	    Rails.logger.info(str)
	    render inline: str
    end

    def post2
	settings = Devise.omniauth_configs[:saml].strategy
	settings.compress_request = false
	saml_request = OneLogin::RubySaml::Authrequest.new
	#@post_params = saml_request.create_params(settings,params)
	params.delete("controller")
	params.delete("action")
	@saml_login_url = settings.idp_sso_target_url
	render :show
    end

    def idp_logout_request

	    Rails.logger.info('IDP_LOGOUT_REQUEST ++++++++++')
	    settings = Devise.omniauth_configs[:saml].strategy
	    logout_request = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest], :settings => settings)
	    if not logout_request.is_valid?
		    error_msg = "IdP initiated LogoutRequest was not valid!. Errors: #{logout_request.errors}"
		    logger.error error_msg
		    render :inline => error_msg
	    end
	    logger.info "IdP initiated Logout for #{logout_request.nameid}"

	    reset_session
	    logout_response = OneLogin::RubySaml::SloLogoutresponse.new.create(settings, logout_request.id, nil, :RelayState => params[:RelayState])
	    redirect_to logout_response
    end

    def sp_logout_request
	    Rails.logger.info('SP_LOGOUT_REQUEST ++++++++++')
	    options = Devise.omniauth_configs[:saml].strategy

	    settings = OneLogin::RubySaml::Settings.new(options)
	    #Rails.logger.info options

	    if settings.idp_slo_target_url.nil?
		    Rails.logger.info "SLO IdP Endpoint not found in settings, executing then a normal logout'"
		    reset_session
	    else
		    logout_request = OneLogin::RubySaml::Logoutrequest.new()
		    session[:transaction_id] = logout_request.uuid
		    Rails.logger.info "New SP SLO for User ID: '#{session[:nameid]}', Transaction ID: '#{session[:transaction_id]}'"
		    if settings.name_identifier_value.nil?
			    settings.name_identifier_value = session['saml_uid']
			    settings.idp_name_qualifier = 'IDP_CdM'
			    settings.sp_name_qualifier = 'https://partecipazione.comune.milano.it' 
			    settings.sessionindex = session["saml_session_index"]
		    end
		    relayState = url_for controller: 'sso_login', action: 'logout'
		    #begin
			#    request = logout_request.create(settings, :RelayState => relayState)
		    #rescue
			#    Rails.logger.info($!.backtrace)
		    #end
		    #redirect_to(request)
		    #
		    #request = logout_request.create(settings)
		    params = logout_request.create_params(settings)
		    #params = request.split(/[\?&]/)
		    #url = params[0]
		    #saml_request = params[1]
		    #relay_state = params[2]

		form_params = {
			url: settings.idp_slo_target_url, 
			saml_request: params['SAMLRequest'], 
			relay_state: relayState
		}
		#Rails.logger.info(' ============ PARAMETRI DEL FORM ===============')
		#Rails.logger.info(form_params)

		#con = Faraday::Connection.new form_params[:url]
		#res = con.post '', {'SAMLRequest' => form_params[:saml_request], 'RelayState' => form_params[:relay_state]}
		#Rails.logger.info('RISPOSTA:')
		#Rails.logger.info(res.body)

		#pattern = /<input type="hidden" name="SAMLResponse" value="(.+)" \/>/

		#if res.body.match pattern
		#	new_saml_request = CGI.unescape_html($1)
		#	Rails.logger.info("FOUND #{new_saml_request}")
		#	new_saml_request2 = new_saml_request.gsub(/[\r\n]/,"")
		#	Rails.logger.info("CONVERTITO:")
		#	Rails.logger.info(new_saml_request2)
		#else
		#	raise StandardError
		#end

		#form_params = {
		#	url: relayState,
		#	saml_request: new_saml_request2,
		#	relay_state: relayState
		#}

		
		render 'logout_request', locals: form_params
		    #render 'logout_request', locals: {url: url, saml_request: saml_request, relay_state: relay_state}
		    #connection = Faraday::Connection.new url
		    #response = connection.post('', {'SAMLRequest' => saml_request, 'RelayState' => relay_state} )
		    #Rails.logger.info(response.headers)
		    #Rails.logger.info(response.body)
		    #redirect_to(url_for controller: 'application', action: 'index')
		    #redirect_to(response.headers['location'])
	    end
    end

    def process_logout_response
	    Rails.logger.info('+-+-++-+-+--+-+-+-+-+-+--+-+-+-+- LOGOUT RESPONSE')
	    Rails.logger.info(params['SAMLRequest'])
	    settings = Devise.omniauth_configs[:saml].strategy
	    request_id = session[:transaction_id]
	    logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings, :matches_request_id => request_id, :get_params => params)
	    logger.info "LogoutResponse is: #{logout_response.response.to_s}"

	    if not logout_response.validate
		    error_msg = "The SAML Logout Response is invalid.  Errors: #{logout_response.errors}"
		    logger.error error_msg
		    render :inline => error_msg
	    else
		    if logout_response.success?
			    logger.info "Delete session for '#{session[:nameid]}'"
			    reset_session
		    end
	    end
    end

    def metadata
	    settings = Account.get_saml_settings(get_url_base)
	    meta = OneLogin::RubySaml::Metadata.new
	    render :xml => meta.generate(settings, true)
    end

    def get_url_base
	    "#{request.protocol}#{request.host_with_port}"
    end

    def idp_logout_request_NOK
	    Rails.logger.info('SP_LOGOUT_RESPONSE ++++++++++')
            options = Devise.omniauth_configs[:saml].strategy
            settings = OneLogin::RubySaml::Settings.new(options)    
    end

end
