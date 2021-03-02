# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin answers a proposal.
      class AnswerProposal < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # proposal - The proposal to write the answer for.
        def initialize(form, proposal)
          @form = form
          @proposal = proposal
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          @amendment ||= Decidim::Amendment.find_by(decidim_emendation_id: proposal.id)
          if(@amendment)
            answer_proposal_custom
            update_amendments!
            update_proposal!
            notify_amendable_authors_and_followers
          else
            answer_proposal
          end

#          answer_proposal
          notify_followers
          increment_score

          broadcast(:ok)
        end

        private

        attr_reader :form, :proposal

        def answer_proposal_custom
	   a = Decidim::Amendment.find_by(:decidim_emendation_id => proposal.id)
           a.state = @form.state
           a.answer = @form.answer.to_json
           a.answered_at = Time.current
           a.save!
	   form.answer = nil
	end

        def answer_proposal
        # @amendment ||= Decidim::Amendment.find_by(decidim_emendation_id: proposal.id)
          Decidim.traceability.perform_action!(
            "answer",
            proposal,
           form.current_user
          )  do
            proposal.update!(
              state: @form.state,
              answer: @form.answer,
              answered_at: Time.current
            )
         end
        end

        def update_proposal!
        @proposal_custom ||= Decidim::Proposals::Proposal.find_by(id:@amendment.decidim_amendable_id)
          if (@form.state.to_s == 'accepted')
            @proposal_custom.update!(
              body: proposal.body
            )
          end
        end

        def update_amendments!
        creator_author = Decidim::User.find_by(id:@amendment.id)
          @amendment = Decidim.traceability.update!(
          @amendment,
          creator_author,
          { state: @form.state }
        )
         # @amendment.emendation.update!(state: @form.state)
        end

      def waiting_emendation!
              @amendment.emendation.update!(state: @form.state)
        #PaperTrail.request(enabled: false) do
        # @amendment.emendation.update!(state: @form.state)
       # end
      end

        def notify_followers
          return if (proposal.previous_changes.keys & %w(state)).empty?

          if proposal.accepted?
            publish_event(
              "decidim.events.proposals.proposal_accepted",
              Decidim::Proposals::AcceptedProposalEvent
            )
          elsif proposal.rejected?
            publish_event(
              "decidim.events.proposals.proposal_rejected",
              Decidim::Proposals::RejectedProposalEvent
            )
          elsif proposal.evaluating?
            publish_event(
              "decidim.events.proposals.proposal_evaluating",
              Decidim::Proposals::EvaluatingProposalEvent
            )
          end
        end

        def publish_event(event, event_class)
          Decidim::EventsManager.publish(
            event: event,
            event_class: event_class,
            resource: proposal,
            affected_users: proposal.notifiable_identities,
            followers: proposal.followers - proposal.notifiable_identities
          )
        end

        def increment_score
          return unless proposal.accepted?

          proposal.coauthorships.find_each do |coauthorship|
            if coauthorship.user_group
              Decidim::Gamification.increment_score(coauthorship.user_group, :accepted_proposals)
            else
              Decidim::Gamification.increment_score(coauthorship.author, :accepted_proposals)
            end
          end
        end

        def notify_amendable_authors_and_followers

          if (@amendment.state == 'accepted')
            publish_amendment_event(
              "decidim.events.amendments.amendment_accepted",
              Decidim::Amendable::AmendmentAcceptedEvent
            )
          elsif (@amendment.state == 'rejected')
            publish_amendment_event(
              "decidim.events.amendments.amendment_rejected",
              Decidim::Amendable::AmendmentRejectedEvent
            )

          end
        end

        def publish_amendment_event(event, event_class)

           affected_users = @amendment.emendation.authors + @amendment.amendable.notifiable_identities
           followers = @amendment.emendation.followers + @amendment.amendable.followers - affected_users

           Decidim::EventsManager.publish(
            event: event,
            event_class: Decidim::Amendable::AmendmentCreatedEvent, #event_class,
            resource: @proposal_custom,
            affected_users: affected_users, #@proposal_custom.notifiable_identities,
            followers: followers #@proposal_custom.followers - @proposal_custom.notifiable_identities
          )
        end
      end
    end
  end
end

