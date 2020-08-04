defmodule TemplateTest do
  use ExUnit.Case
  use QuizBuilders

  def setup_template(context) do
    fields = template_fields()
    template = Template.new(fields)

    {:ok, Map.put(context, :setup_template, %{fields: fields, template: template})}
  end

  describe "a group of tests needing :setup_template" do
    setup [:setup_template]

    test "building compiles the raw template", %{setup_template: data} do
      assert is_nil(Keyword.get(data.fields, :compiled))
      assert not is_nil(data.template.compiled)
    end

    test "question builds template", %{setup_template: data} do
      Question.new(data.template)
    end
  end
end
