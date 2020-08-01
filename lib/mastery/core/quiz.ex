defmodule Mastery.Core.Quiz do
  @moduledoc """
  title (String.t)
    The title for a quiz.
  mastery (integer)
    The number of questions a user must get right to master a quiz category.

  current_question (Question.t)
    The current question being presented to the user.
  last_response (Response.t)
    The last response given by the user.
  templates (%{ "category" => [Template.t]})
    The master list of templates, by category.
  used ([Template.t])
    The templates that we’ve used, this cycle, that have not yet been mastered.
  mastered ([Template.t])
    The templates that have been mastered.
  record (%{ "template_name" => integer})
    The number of correct answers in a row a user has given for each template.
  """
  defstruct title: nil,
            mastery: 3,
            current_question: nil,
            last_response: nil,
            templates: %{},
            used: [],
            mastered: [],
            record: %{}
end
