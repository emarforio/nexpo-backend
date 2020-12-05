defmodule Nexpo.FormView do
    use Nexpo.Web, :view
  
    def render("index.json", %{forms: forms}) do
      %{data: render_many(forms, Nexpo.FormView, "form.json")}
    end
  
    def render("show.json", %{form: form}) do
      %{data: render_one(form, Nexpo.FormView, "form.json")}
    end
  
    def render("form.json", %{form: form}) do
      base = [
        :id,
        :template
      ]
  
      Nexpo.Support.View.render_object(form, base)
    end
  end
  