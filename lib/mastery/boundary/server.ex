defmodule Mastery.Boundary.Server do
  alias Mastery.Core.{Quiz, Response}
  use GenServer

  def init(quiz_fields) do
    {:ok, Quiz.new(quiz_fields)}
  end

  def handle_call({:add_template, template_fields}, _from, quiz) do
    quiz =
      quiz
      |> Quiz.add_template(template_fields)

    {:reply, :ok, quiz}
  end

  def handle_call(:start_quiz, _from, quiz) do
    quiz =
      quiz
      |> Quiz.select_question()

    {:reply, quiz.current_question.asked, quiz}
  end

  def handle_call({:answer, email, answer}, _from, quiz) do
    quiz =
      quiz
      |> Quiz.answer_question(Response.new(quiz, email, answer))
      |> Quiz.select_question()

    if is_nil(quiz) do
      {:reply, :finished, nil}
    else
      {:reply, {quiz.current_question.asked, quiz.last_response.correct}, quiz}
    end
  end

  def handle_call(:finished?, _from, quiz) do
    {:reply, is_nil(quiz), quiz}
  end
end
