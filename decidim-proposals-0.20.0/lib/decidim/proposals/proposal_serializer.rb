# frozen_string_literal: true

module Decidim
  module Proposals
    # This class serializes a Proposal so can be exported to CSV, JSON or other
    # formats.
    class ProposalSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a proposal.
      def initialize(proposal)
        @proposal = proposal
      end

      # Public: Exports a hash with the serialized data for this proposal.
      def serialize

        # *************** LUCA
              user_id_query = "SELECT decidim_author_id FROM decidim_coauthorships as t1 JOIN decidim_proposals_proposals as t2 ON t1.coauthorable_id = t2.id AND t1.coauthorable_type = 'Decidim::Proposals::Proposal' WHERE t2.id = '#{@proposal.id}' limit 1"
        user_id = ActiveRecord::Base.connection.execute(user_id_query)
        @author_name = Decidim::User.find(user_id[0]['decidim_author_id']).name
        # *********************

        {
          id: proposal.id,
          category: {
            id: proposal.category.try(:id),
            name: proposal.category.try(:name) || empty_translatable
          },
          scope: {
            id: proposal.scope.try(:id),
            name: proposal.scope.try(:name) || empty_translatable
          },
          participatory_space: {
            id: proposal.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(proposal.participatory_space).url
          },
          component: { id: component.id },
          title: present(proposal).title,
          body: present(proposal).body,
          state: proposal.state.to_s,
          reference: proposal.reference,
          answer: ensure_translatable(proposal.answer),
          supports: proposal.proposal_votes_count,
          endorsements: {
            total_count: proposal.endorsements.count,
            user_endorsements: user_endorsements
          },
          author: @author_name.to_s,
          comments: proposal.comments.count,
          attachments: proposal.attachments.count,
          followers: proposal.followers.count,
          published_at: proposal.published_at,
          url: url,
          meeting_urls: meetings,
          related_proposals: related_proposals,
          is_amend: proposal.emendation?,
          original_proposal: {
            title: proposal&.amendable&.title,
            url: original_proposal_url
          }
        }
      end

      private

      attr_reader :proposal

      def component
        proposal.component
      end

      def meetings
        proposal.linked_resources(:meetings, "proposals_from_meeting").map do |meeting|
          Decidim::ResourceLocatorPresenter.new(meeting).url
        end
      end

      def related_proposals
        proposal.linked_resources(:proposals, "copied_from_component").map do |proposal|
          Decidim::ResourceLocatorPresenter.new(proposal).url
        end
      end

      def url
        Decidim::ResourceLocatorPresenter.new(proposal).url
      end

      def user_endorsements
        proposal.endorsements.for_listing.map { |identity| identity.normalized_author&.name }
      end

      def original_proposal_url
        return unless proposal.emendation? && proposal.amendable.present?

        Decidim::ResourceLocatorPresenter.new(proposal.amendable).url
      end
    end
  end
end

