# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :questionnaire, class: Decidim::Forms::Questionnaire do
    title { generate_localized_title }
    description do
      Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        generate_localized_title
      end
    end
    tos { generate_localized_title }
    questionnaire_for { build(:participatory_process) }

    trait :with_questions do
      questions do
        qs = %w(short_answer long_answer).collect do |text_question_type|
          build(:questionnaire_question, question_type: text_question_type)
        end
        qs << build(:questionnaire_question, :with_answer_options, question_type: :single_option)
        qs
      end
    end
  end

  factory :questionnaire_question, class: Decidim::Forms::Question do
    transient do
      options { [] }
    end

    body { generate_localized_title }
    mandatory { false }
    position { 0 }
    question_type { Decidim::Forms::Question::TYPES.first }
    questionnaire

    before(:create) do |question, evaluator|
      if question.answer_options.empty?
        evaluator.options.each do |option|
          question.answer_options.build(
            body: option["body"],
            free_text: option["free_text"]
          )
        end
      end
    end

    trait :with_answer_options do
      answer_options do
        Array.new(3).collect { build(:answer_option) }
      end
    end
  end

  factory :answer, class: Decidim::Forms::Answer do
    body { "hola" }
    questionnaire
    question { create(:questionnaire_question, questionnaire: questionnaire) }
    user { create(:user, organization: questionnaire.questionnaire_for.organization) }
  end

  factory :answer_option, class: Decidim::Forms::AnswerOption do
    question { create(:questionnaire_question) }
    body { generate_localized_title }
    free_text { false }
  end

  factory :answer_choice, class: Decidim::Forms::AnswerChoice do
    answer
    answer_option { create(:answer_option, question: answer.question) }
  end
end
