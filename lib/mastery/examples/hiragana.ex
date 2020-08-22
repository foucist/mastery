defmodule Mastery.Examples.Hiragana do
  alias Mastery.Core.Quiz
  # @hiraganas %{"い" => "i", "あ" => "a", "う" => "u", "え" => "e", "お" => "o"}
  @hiraganas %{い: "i", あ: "a", う: "u", え: "e", お: "o"}

  def quiz do
    quiz_fields()
    |> Quiz.new()
    |> Quiz.add_template(template_fields())
  end

  def quiz_fields, do: %{mastery: 5, title: :simple_hiragana}

  def template_fields do
    [
      name: :single_hiragana_syllablary,
      category: :hiragan,
      instructions: "Type the hiragana syllable",
      raw: "<%= @left %>",
      generators: addition_generators(),
      checker: &addition_checker/2
    ]
  end

  def addition_generators, do: %{left: Map.keys(@hiraganas)}

  def addition_checker(substitutions, answer) do
    left = Keyword.fetch!(substitutions, :left)
    @hiraganas[left] == String.trim(answer)
  end
end
