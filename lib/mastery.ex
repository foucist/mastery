defmodule Mastery do
  alias Mastery.Boundary.{QuizSession, QuizManager}
  alias Mastery.Boundary.{TemplateValidator, QuizValidator}
  alias Mastery.Core.Quiz

  def start_quiz_manager() do
    GenServer.start_link(QuizManager, %{}, name: QuizManager)
  end

  def build_quiz(fields) do
    with :ok <- QuizValidator.errors(fields),
         :ok <- GenServer.call(QuizManager, {:build_quiz, fields}) do
      :ok
    else
      error -> error
    end
  end

  def add_template(title, fields) do
    with :ok <- TemplateValidator.errors(fields),
         :ok <- GenServer.call(QuizManager, {:add_template, title, fields}) do
      :ok
    else
      error -> error
    end
  end

  def take_quiz(title, email) do
    with %Quiz{} = quiz <- QuizManager.lookup_quiz_by_title(title),
         {:ok, pid} <- GenServer.start_link(QuizSession, {quiz, email}) do
      pid
    else
      error -> error
    end
  end

  def select_question(pid) do
    GenServer.call(pid, :select_question)
  end

  def answer_question(pid, answer) do
    GenServer.call(pid, {:answer_question, answer})
  end

  alias Mastery.Examples.Hiragana

  def start_hiragana do
    Mastery.start_quiz_manager()
    Mastery.build_quiz(Hiragana.quiz_fields())
    Mastery.add_template(Hiragana.quiz().title, Hiragana.template_fields())
    pid = Mastery.take_quiz(Hiragana.quiz().title, "mathy@email.com")
    q = Mastery.select_question(pid)
    question_answer_loop(q, pid)
  end

  def question_answer_loop([current_q, next_q], pid) do
    a = IO.gets("What is this hiragana: #{current_q}?             #{next_q}\n")

    case Mastery.answer_question(pid, a) do
      {q, r} ->
        display_response(r) |> IO.puts()
        question_answer_loop(q, pid)

      :finished ->
        "Correct! You have achieved mastery"
    end
  end

  def display_response(true), do: "Correct"
  def display_response(false), do: "Wrong"
end
