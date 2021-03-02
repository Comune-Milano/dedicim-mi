class CourtesyPageController < ApplicationController
    def show
	   @parameters = Array.new
     logger.warn "*** BEGIN FAKE LOGIN ***"
     self.request.headers.each do |header|
	  
        if header[0].include? "HTTP_CDM"
           logger.warn "HEADER KEY: #{header[0]}"
           logger.warn "HEADER VAL: #{header[1]}"
	   
	   @parameters.push(header[0].sub("HTTP_CDM_","") + ": " +  header[1])
        end
     end
     logger.warn "*** END FAKE LOGIN ***"
	render template: "decidim/courtesy_page/index.html.erb"
 
    end
  end 
