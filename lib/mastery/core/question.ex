defmodule Mastery.Core.Question do
  @moduledoc """
  asked (String.t)
    The question text for a user. For example, "1 + 2".
  template (Template.t)
    The template that created the question.
  substitutions (%{ substitution: any})
    The values chosen for each substitution field in a template. For example, for a template <%= left %> + <%= right %>, the substitutions might be %{ "left" => 1, "right" => 2}.
  """

  defstruct ~w[asked template substitutions]a
end
