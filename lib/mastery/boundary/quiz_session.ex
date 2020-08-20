# Quiz Manager server
defmodule Mastery.Boundary.QuizSession do
  alias Mastery.Core.{Quiz, Response}
  use GenServer

  #####
  # External API

  def init({quiz, email}) do
    {:ok, {quiz, email}}
  end

  def start_link({quiz, email}) do
    GenServer.start_link(__MODULE__, {quiz, email}, name: __MODULE__)
  end

  def select_question(session) do
    GenServer.call(session, :select_question)
  end

  def answer_question(session, answer) do
    GenServer.call(session, {:answer_question, answer})
  end

  ####
  # GenServer implementation

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

  defp next_or_done(_quiz = nil, _email), do: {:stop, :normal, :finished, nil}

  # reply with current question and last response's score
  defp next_or_done(quiz, email) do
    {:reply, {quiz.current_question.asked, quiz.last_response.correct}, {quiz, email}}
  end
end