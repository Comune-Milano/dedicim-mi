class EditNotAllowedController < ApplicationController

  respond_to :js, :html

  def check

    proposal_id = params[:proposal_id]
    url = params[:url]

    #Rails.logger.info "\n\n\n"
    #Rails.logger.info "proposal id: "+proposal_id.to_s

    votes = Decidim::Proposals::Proposal.find(proposal_id.to_i).proposal_votes_count
    endorsements = Decidim::Proposals::Proposal.find(proposal_id.to_i).proposal_endorsements_count
    comments = Decidim::Comments::Comment.where("decidim_commentable_id = ? AND decidim_commentable_type = ?", proposal_id.to_i, 'Decidim::Proposals::Proposal').count

    #Rails.logger.info "\n\n\n"
    #Rails.logger.info "Voti: "+votes.to_s+"\n"
    #Rails.logger.info "Approvazioni: "+endorsements.to_s+"\n"
    #Rails.logger.info "Commenti: "+comments.to_s+"\n"

    respond_to do |format|
        if votes.to_i > 0 or endorsements.to_i > 0 or comments.to_i > 0
          format.js { render :js => "document.getElementById('myModal4').style.display = 'block';" }
        else
          format.html { redirect_to url.to_s+"/edit" }
          format.js { render :js => "window.location.href = '"+url.to_s+"/edit';" }
        end
    end




  end

end

