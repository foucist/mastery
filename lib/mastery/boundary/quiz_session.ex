defmodule Mastery.Boundary.QuizSession do
  alias Mastery.Core.{Quiz, Response}
  use GenServer

  def select_question(pid) do
    GenServer.call(pid, :select_question)
  end

  def answer_question(pid, answer) do
    GenServer.call(pid, {:answer_question, answer})
  end

  def init({quiz, email}) do
    {:ok, {quiz, email}}
  end

  def handle_call(:select_question, _from, {quiz, email}) do
    quiz = Quiz.select_question(quiz)

    {:reply, quiz.current_question.asked, {quiz, email}}
  end

  def handle_call({:answer_question, answer}, _from, {quiz, email}) do
    response = Response.new(quiz, email, answer)

    quiz
    |> Quiz.answer_question(response)
    |> Quiz.select_question()
    |> next_or_done(email)
  end

  defp next_or_done(nil = _quiz, _email), do: {:stop, :normal, :finished, nil}

  defp next_or_done(quiz, email) do
    {:reply, {quiz.current_question.asked, quiz.last_response.correct}, {quiz, email}}
  end
end
