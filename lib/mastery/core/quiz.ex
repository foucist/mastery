defmodule Mastery.Core.Quiz do
  alias Mastery.Core.{Template, Question, Response}

  defstruct title: nil,
            mastery: 3,
            templates: %{},
            used: [],
            current_questions: [],
            last_response: nil,
            record: %{},
            mastered: []

  def new(fields) do
    struct!(__MODULE__, fields)
  end

  def add_template(quiz, fields) do
    template = Template.new(fields)

    templates = update_in(quiz.templates, [template.category], &add_to_list_or_nil(&1, template))

    %{quiz | templates: templates}
  end

  defp add_to_list_or_nil(nil, template), do: [template]
  defp add_to_list_or_nil(templates, template), do: [template | templates]

  def select_question(%__MODULE__{templates: t}) when map_size(t) == 0, do: nil

  def select_question(quiz) do
    quiz
    |> pick_current_questions

    # |> move_template(:used)
    # |> reset_template_cycle
  end

  defp pick_current_questions(quiz) do
    Map.put(quiz, :current_questions, fill_questions(quiz.current_questions, quiz))
  end

  defp fill_questions([], quiz), do: [get_random_question(quiz), get_random_question(quiz)]
  defp fill_questions([_curr, next], quiz), do: [next, get_random_question(quiz)]

  defp get_random_question(quiz) do
    quiz.templates
    |> Enum.random()
    |> elem(1)
    |> Enum.random()
    |> Question.new()
  end

  defp move_template(quiz, field) do
    quiz
    |> remove_template_from_category
    |> add_template_to_field(field)
  end

  defp template(%{current_questions: [question, _]} = _quiz), do: question.template

  defp remove_template_from_category(quiz) do
    template = template(quiz)

    new_category_templates =
      quiz.templates
      |> Map.fetch!(template.category)
      |> List.delete(template)

    new_templates =
      if new_category_templates == [] do
        Map.delete(quiz.templates, template.category)
      else
        Map.put(quiz.templates, template.category, new_category_templates)
      end

    Map.put(quiz, :templates, new_templates)
  end

  defp add_template_to_field(quiz, field) do
    template = template(quiz)
    list = Map.get(quiz, field)

    Map.put(quiz, field, [template | list])
  end

  defp reset_template_cycle(%{templates: templates, used: used} = quiz)
       when map_size(templates) == 0 do
    new_templates = Enum.group_by(used, fn template -> template.category end)

    %__MODULE__{quiz | templates: new_templates, used: []}
  end

  defp reset_template_cycle(quiz), do: quiz

  def answer_question(quiz, %Response{correct: true} = response) do
    quiz =
      quiz
      |> inc_record
      |> save_response(response)

    next_quiz(quiz, mastered?(quiz))
  end

  def answer_question(quiz, %Response{correct: false} = response) do
    quiz
    |> reset_record
    |> save_response(response)
  end

  defp inc_record(%{current_questions: [question, _]} = quiz) do
    new_record = Map.update(quiz.record, question.template.name, 1, &(&1 + 1))
    Map.put(quiz, :record, new_record)
  end

  def mastered?(quiz) do
    score = Map.get(quiz.record, template(quiz).name, 0)
    score == quiz.mastery
  end

  defp next_quiz(quiz, false = _mastered), do: quiz
  defp next_quiz(quiz, true = _mastered), do: advance(quiz)

  def advance(quiz) do
    quiz
    |> move_template(:mastered)
    |> reset_record
    |> reset_used
  end

  defp reset_record(%{current_questions: [question, _]} = quiz) do
    Map.put(quiz, :record, Map.delete(quiz.record, question.template.name))
  end

  defp reset_used(%{current_questions: [question, _]} = quiz) do
    Map.put(quiz, :used, List.delete(quiz.used, question.template))
  end

  def save_response(quiz, response) do
    Map.put(quiz, :last_response, response)
  end
end
