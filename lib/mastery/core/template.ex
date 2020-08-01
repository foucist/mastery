defmodule Mastery.Core.Template do
  @moduledoc """
  ## These are the fields that describe our template:

  name (atom)
    The name of this template.
  category (atom)
    A grouping for questions of the same name.
  instructions (string)
    A string telling the user how to answer questions of this type.

  ## These are the fields that support question generation:

  raw (string)
    The template code before compilation.
  compiled (macro)
    The compiled version of the template for execution.
  generators (%{ substitution: list or function})
    The generator for each substitution in a template. Each generator is a list of elements or a function. Generating a template substitution will either fire the function or pick a random item from the list.

  ## This is the field for processing responses:

  checker (function(substitutions, string) -> boolean)
    Given the substitutions strings and an answer, the function returns true if the answer is correct. For example, fn subs, answer -> to_string(subs.left + subs.right) == String.trim(answer) end).
  """

  # We can use the data structure to:
  # • Represent a grouping of questions on a quiz
  # • Generate questions with a compilable template and functions
  # • Check the response of a single question in the template

  defstruct ~w[name category instructions raw compiled generators checker]a
end
