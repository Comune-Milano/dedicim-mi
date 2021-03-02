class LoginErrorController < ApplicationController

    #skip_before_action :verify_authenticity_token
    
    def index
	    render :file => "app/views/decidim/login_error/index.html.erb"
    end

end
