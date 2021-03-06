defmodule Mastery.Core.Question do
  alias Mastery.Core.Template

  defstruct ~w[asked substitutions template]a

  def new(%Template{} = template) do
    template.generators
    |> build_substitutions
    |> evaluate(template)
  end

  def build_substitutions(generators) do
    Enum.map(generators, fn {name, choices_or_generator} ->
      {name, choose(choices_or_generator)}
    end)
  end

  defp choose(choices) when is_list(choices) do
    Enum.random(choices)
  end

  defp choose(generator) when is_function(generator) do
    generator.()
  end

  defp evaluate(substitutions, template) do
    %__MODULE__{
      asked: compile(template, substitutions),
      substitutions: substitutions,
      template: template
    }
  end

  defp compile(template, substitutions) do
    template.compiled
    |> Code.eval_quoted(assigns: substitutions)
    |> elem(0)
  end
end
