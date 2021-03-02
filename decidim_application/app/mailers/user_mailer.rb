class UserMailer < ApplicationMailer

  include Decidim::TranslatableAttributes
  include Decidim::SanitizeHelper

  add_template_helper Decidim::TranslatableAttributes
  add_template_helper Decidim::SanitizeHelper


  def notify_officialize_user
      @user = params[:user]
      @body = "Ciao #{ @user.name } e benvenuto su Milano Partecipa!<br />La tua richiesta è stata autorizzata. Puoi entrare subito nella piattaforma e partecipare in qualità di City User.<br />Per ulteriori informazioni sulle regole di partecipazione per i City User, visita la pagina di <a href='https://partecipazione.comune.milano.it/pages/cityuser'>Aiuto</a>.<br /><br />A presto,<br />Lo staff di Milano Partecipa"
      @subject = "Milano Partecipa ti d\u00E0 il benvenuto!"
      mailer = ActionMailer::Base.new
      mailer.delivery_method
      mailer.smtp_settings
      result = mailer.mail(
        from: mailer.smtp_settings.to_hash[:from],
        to: "#{@user.name} <#{@user.email}>",
        subject: @subject,
        body: @body.html_safe,
        content_type: 'text/html'
      ).deliver
  end

  def notify_rifiuto
      @user = params[:user]
      @body = "Ciao #{ @user.name }!<br />
Abbiamo riscontrato un'anomalia nella tua auto-certificazione, per cui ti chiediamo di verificare i dati e compilare di nuovo il modulo online con le informazioni corrette.
Per ulteriori informazioni sulle regole di partecipazione per i City User, visita la pagina di <a href='https://partecipazione.comune.milano.it/pages/cityuser'>Aiuto</a>.<br /><br />A presto,<br />Lo staff di Milano Partecipa"
      @subject = "Auto-certificazione per City User"
      mailer = ActionMailer::Base.new
      mailer.delivery_method
      mailer.smtp_settings
      result = mailer.mail(
        from: mailer.smtp_settings.to_hash[:from],
        to: "#{@user.name} <#{@user.email}>",
        subject: @subject,
        body: @body.html_safe,
        content_type: 'text/html'
      ).deliver
  end


end

