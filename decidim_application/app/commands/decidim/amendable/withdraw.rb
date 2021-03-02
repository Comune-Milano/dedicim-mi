# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic to withdraw an amendment.
    class Withdraw < Rectify::Command
      # Public: Initializes the command.
      #
      # amendment     - The amendment to withdraw.
      # current_user  - The current user.
      def initialize(amendment, current_user)
        @amendment = amendment
        @amender = amendment.amender
        @current_user = current_user
        @emendation = amendment.emendation
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource already has supports or does not belong to current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @amendment.state == 'accepted'      
        #controllo se ci sono "mi piace" e "commenti" nella proposta. Se ci sono impedisco il ritiro
        query0 = "select decidim_emendation_id from decidim_amendments where id = '#{@amendment.id}'"
        result =  ActiveRecord::Base.connection.execute(query0)
        proposal_id = result.first["decidim_emendation_id"]
        query1 = "SELECT count(id) FROM decidim_proposals_proposal_endorsements where decidim_proposal_id = '#{proposal_id}'"
        query2 = "SELECT count(id) FROM decidim_comments_comments where decidim_commentable_type like '%Proposal' and decidim_commentable_id = '#{proposal_id}'"
        endorsements_count = ActiveRecord::Base.connection.execute(query1)
        numero_mipiace = endorsements_count.first["count"]
        comments_count = ActiveRecord::Base.connection.execute(query2)
        numero_commenti = comments_count.first["count"]
        Rails.logger.info "\n\n\nINIZIO LOG di RITIRO OSSERVAZIONE\n"
        Rails.logger.info "Query: #{query0}"
        Rails.logger.info "Query: #{query1}"
        Rails.logger.info "Query: #{query2}"
        Rails.logger.info "Amendment id: #{@amendment.id}"
        Rails.logger.info "Osservazione id: #{proposal_id}"
        Rails.logger.info "Numero di mi piace #{numero_mipiace}"
        Rails.logger.info "Numero di commenti #{numero_commenti}"
        Rails.logger.info "\nFINE LOG\n\n\n" 
        return broadcast(:invalid) if numero_mipiace.to_i > 0 || numero_commenti.to_i > 0
        return broadcast(:invalid) unless emendation.votes.empty? && amender == current_user

        transaction do
          withdraw_amendment!
          withdraw_emendation!
        end

        broadcast(:ok, emendation)
      end

      private

      attr_reader :amendment, :amender, :current_user, :emendation

      def withdraw_amendment!
        @amendment = Decidim.traceability.update!(
          amendment,
          current_user,
          { state: "withdrawn" },
          visibility: "public-only"
        )
      end

      # Unlike other Amendable commands, we need to update the state of the
      # emendation for the scope Decidim::Proposals::Proposal::expect_withdrawn
      # to be able to retrieve rejected emendations.
      #
      # Because we are modifying the emendation itself, we need to prevent
      # PaperTrail from creating an additional version to ensure that this
      # change does not appear in the diff renderer of the emendation page.
      def withdraw_emendation!
        PaperTrail.request(enabled: false) do
          emendation.update!(state: "withdrawn")
        end
      end
    end
  end
end
