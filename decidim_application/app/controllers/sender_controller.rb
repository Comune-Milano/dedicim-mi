class SenderController < ApplicationController

    def index

        
        body = "<p>C'è una nuova richiesta di autenticazione su Milano Partecipa da parte di un City User in attesa di risposta.</p>"
	body = body + "<p>Inviata da: " + current_user.name + "</p>"
	##body = body + "<p>Email: " + current_user.email + "</p>"
        ##body = body + "<p>Richiesta:</p> "	
	##body = body +  "<p>" + params[:sondaggio] + "</p>"
	name_query = current_user.name.gsub! ' ', '+'
	body = body + '<p><a href="' + self.request.headers['HTTP_ORIGIN']  +'/admin/officializations">Qui il LINK</a></p>'
	logger.info "ORIGIN" + body


      #invio l'email a tutti gli admin
	
      Decidim::User.all.each do |user|
        if user.admin?
		mailer = ActionMailer::Base.new
        	mailer.delivery_method
        	mailer.smtp_settings
		result = mailer.mail(
			from: mailer.smtp_settings.to_hash[:from], 
		        to: user.email , 
			subject: 'Richiesta autenticazione City User su Milano Partecipa', 
			body: body,
		 	content_type: 'text/html'
		).deliver

		          
	  
	  
        end
      end

       @currentUser  = Decidim::User.find_by(id: current_user.id.to_s)
         @currentUser.update!(
                form_inviato: true,
                richiesta_at: Time.current
                #body_richiesta: params[sondaggio]
                )

      #chiudo il modal
      	respond_to do |format|      
        format.js { render :js => "document.getElementById('myModal').style.display = 'none'; document.getElementById('myModal3').style.display = 'block';
	  document.getElementById('button-close3').onclick = function() { document.getElementById('myModal3').style.display = 'none'; window.location.reload(); }" }	
      end
     
    end

end
