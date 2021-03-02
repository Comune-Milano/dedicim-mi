Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  mount Decidim::Core::Engine => '/decidim' #modificato per il context da '/'
   get '/' => 'application#redirect_to_decidim'            #aggiunto per il context
  # get '/decidim' => "ssologin#login" 
   get '/decidim/ssologin' => "sso_login#pippo" 
 # post '/decidim' => "sso_login#debug"
   get '/decidim/logout' => 'sso_login#logout'
  
  #root to "application#index"
  # get 'system' => "system_redirect#redirect"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/login_error' => 'login_error#index'

  get '/users/sign_in' => "application#customredirect"

  post "/decidim/sender" => "sender#index" #invia la mail del form di partecipazione

  get "/decidim/under_construction" => "courtesy_page#show"
   
end
