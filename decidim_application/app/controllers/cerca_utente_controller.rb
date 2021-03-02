class CercaUtenteController < ApplicationController

  #skip_before_action :verify_authenticity_token

  def cerca_utente
    nickname = params['nickname'].gsub('@', '');
    result = Decidim::User.find_by(nickname: nickname.to_s)
    isAdmin = result.admin?
    #Rails.logger.info "\n\n\nAmministratore? "+isAdmin.to_s+"\n\n\n"
    render inline: isAdmin.to_s
  end

end

