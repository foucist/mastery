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
         {:ok, session} <- GenServer.start_link(QuizSession, {quiz, email}) do
      session
    else
      error -> error
    end
  end

  def select_question(session) do
    GenServer.call(session, :select_question)
  end

  def answer_question(session, answer) do
    GenServer.call(session, {:answer_question, answer})
  end

  alias Mastery.Examples.Hiragana

  def start_hiragana do
    Mastery.start_quiz_manager()
    Mastery.build_quiz(Hiragana.quiz_fields())
    Mastery.add_template(Hiragana.quiz().title, Hiragana.template_fields())
    session = Mastery.take_quiz(Hiragana.quiz().title, "mathy@email.com")
    q = Mastery.select_question(session)
    question_answer_loop(q, session)
  end

  def question_answer_loop(question, session) do
    a = IO.gets("What is this hiragana: #{question}?\n")

    case Mastery.answer_question(session, a) do
      {q, r} ->
        display_response(r) |> IO.puts()
        question_answer_loop(q, session)

      :finished ->
        "Correct! You have achieved mastery"
    end
  end

  def display_response(true), do: "Correct"
  def display_response(false), do: "Wrong"
end
