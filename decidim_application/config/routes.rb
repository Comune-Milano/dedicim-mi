Rails.application.routes.draw do
  
  #get 'api', :to => 'deny_api#deny_all', :as => 'deny_api_root'
  #post 'api', :to => 'deny_api#deny_all', :as => 'deny_api_root_post'
  #get 'api/:everything', :to => 'deny_api#deny_all', :as => 'deny_api_page'
  #post 'api/:everything', :to => 'deny_api#deny_all', :as => 'deny_api_pste_post'	
	
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  mount Decidim::Core::Engine => '/'
  #mount Decidim::Core::Engine => '/decidim' #modificato per il context da '/'
  #get '/' => 'application#redirect_to_decidim'            #aggiunto per il context
  
  # get '/decidim' => "ssologin#login" 
   #get '/decidim/ssologin' => "sso_login#pippo"
   get '/ssologin' => "sso_login#pippo" 
 # post '/decidim' => "sso_login#debug"
   #get '/decidim/logout' => 'sso_login#logout'
   get '/logout' => 'sso_login#logout'
   get '/logout/slo' => 'sso_login#sp_logout_request'
   #post '/logout' => 'sso_login#logout'

  #root to "application#index"
  # get 'system' => "system_redirect#redirect"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

	
  get '/login_error' => 'login_error#index'

  get '/users/sign_in' => "application#customredirect"
  get '/paperino' => "application#saml_settings"
  get '/saml2/callback' => "sso_login#post"
  get '/saml2/logout_callback' => 'sso_login#saml_logout'
  post '/users/auth/saml/spslo' => 'sso_login#process_logout_response'

  get '/saml3/callback' => "sso_login#logout_idp"
#  post '/users/auth/saml/slo' => 'sso_login#idp_logout_request'
  #post "/decidim/sender" => "sender#index" #invia la mail del form di partecipazione

  #get "/decidim/under_construction" => "courtesy_page#show"
   

  post "/sender" => "sender#index", :defaults => { :format => 'js' } #invia la mail del form di partecipazione  

  get "/under_construction" => "courtesy_page#show"
  
  get 'edit_not_allowed' => 'edit_not_allowed#check'

end
