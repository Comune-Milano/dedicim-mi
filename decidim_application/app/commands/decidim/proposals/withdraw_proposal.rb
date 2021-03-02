# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user withdraws a new proposal.
    class WithdrawProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # proposal     - The proposal to withdraw.
      # current_user - The current user.
      def initialize(proposal, current_user)
        @proposal = proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :has_supports if the proposal already has supports or does not belong to current user.
      #
      # Returns nothing.
      def call
	return broadcast(:has_supports) if @proposal.state == 'accepted'      
        #controllo se ci sono "mi piace" e "commenti" nella proposta. Se ci sono impedisco il ritiro
        query1 = "SELECT count(id) FROM decidim_proposals_proposal_endorsements where decidim_proposal_id = '#{@proposal.id}'"
        query2 = "SELECT count(id) FROM decidim_comments_comments where decidim_commentable_type like '%Proposal' and decidim_commentable_id = '#{@proposal.id}'"
        endorsements_count = ActiveRecord::Base.connection.execute(query1)
        numero_mipiace = endorsements_count.first["count"]
        comments_count = ActiveRecord::Base.connection.execute(query2)
        numero_commenti = comments_count.first["count"]
        Rails.logger.info "\n\n\nINIZIO LOG di RITIRO PROPOSTA\n"
        Rails.logger.info "Query: #{query1}"
        Rails.logger.info "Query: #{query2}"
        Rails.logger.info "Proposta id: #{@proposal.id}"
        Rails.logger.info "Numero di mi piace #{numero_mipiace}"
        Rails.logger.info "Numero di commenti #{numero_commenti}"
        Rails.logger.info "\nFINE LOG\n\n\n" 
        return broadcast(:has_supports) if numero_mipiace.to_i > 0 || numero_commenti.to_i > 0

        #controllo se ci sono "voti". Se ci sono impedisco il ritiro
        return broadcast(:has_supports) if @proposal.votes.any?

        transaction do
          change_proposal_state_to_withdrawn
          reject_emendations_if_any
        end

        broadcast(:ok, @proposal)
      end

      private

      def change_proposal_state_to_withdrawn
        @proposal.update state: "withdrawn"
      end

      def reject_emendations_if_any
        return if @proposal.emendations.empty?

        @proposal.emendations.each do |emendation|
          @form = form(Decidim::Amendable::RejectForm).from_params(id: emendation.amendment.id)
          result = Decidim::Amendable::Reject.call(@form)
          return result[:ok] if result[:ok]
        end
      end
    end
  end
end
