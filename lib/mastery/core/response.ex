defmodule Mastery.Core.Response do
  @moduledoc """
  quiz_title (String.t)
    Title field from the quiz.
  template_name (atom)
    Name field identifying the template.
  to (String.t)
    The question being answered, as in “this is a response to the asked question.”
  email (String.t)
    The email address of the user answering the question.
  answer (String.t)
    The answer provided by the user.
  correct (boolean)
    Whether the given answer was correct.
  timestamp (Time.t)
    The time the answer was provided.
  """

  defstruct ~w[quiz_title template_name to email answer correct timestamp]a
end
