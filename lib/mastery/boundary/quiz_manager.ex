# Quiz Manager server
defmodule Mastery.Boundary.QuizManager do
  alias Mastery.Core.Quiz
  use GenServer

  #####
  # External API
  def init(quiz_collection) when is_map(quiz_collection) do
    {:ok, quiz_collection}
  end

  def init(_quiz_collection), do: {:error, "quiz_collection must be a map"}

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def build_quiz(manager \\ __MODULE__, quiz_fields) do
    GenServer.call(manager, {:build_quiz, quiz_fields})
  end

  def add_template(manager \\ __MODULE__, quiz_title, template_fields) do
    GenServer.call(manager, {:add_template, quiz_title, template_fields})
  end

  def lookup_quiz_by_title(manager \\ __MODULE__, quiz_title) do
    GenServer.call(manager, {:lookup_quiz_by_title, quiz_title})
  end

  ####
  # GenServer implementation

  def handle_call({:build_quiz, quiz_fields}, _from, quiz_collection) do
    quiz = Quiz.new(quiz_fields)
    updated_quiz_collection = Map.put(quiz_collection, quiz.title, quiz)

    {:reply, :ok, updated_quiz_collection}
  end

  def handle_call({:add_template, quiz_title, template_fields}, _from, quiz_collection) do
    updated_quiz_collection =
      Map.update!(quiz_collection, quiz_title, fn quiz ->
        Quiz.add_template(quiz, template_fields)
      end)

    {:reply, :ok, updated_quiz_collection}
  end

  def handle_call({:lookup_quiz_by_title, quiz_title}, _from, quiz_collection) do
    {:reply, quiz_collection[quiz_title], quiz_collection}
  end
end
