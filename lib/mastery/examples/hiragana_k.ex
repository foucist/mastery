defmodule Mastery.Examples.HiraganaK do
  alias Mastery.Core.Quiz
  @k_map %{"きゃ" => "kya", "きゅ" => "kyu", "きょ" => "kyo"}
  @k_big ["き"]
  @k_small ["ゃ", "ゅ", "ょ"]

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
      raw: "<%= @left %><%= @right %>",
      generators: addition_generators(),
      checker: &addition_checker/2
    ]
  end

  def addition_generators do
    %{left: @k_big, right: @k_small}
  end

  def addition_checker(substitutions, answer) do
    left = Keyword.fetch!(substitutions, :left)
    right = Keyword.fetch!(substitutions, :right)
    @k_map[left <> right] == String.downcase(String.trim(answer))
  end
end
