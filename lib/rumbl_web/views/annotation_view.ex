defmodule RumblWeb.AnnotationView do
  use RumblWeb, :view

  def render("annotation.json", %{annotation: annotation}) do
    %{
      id: annotation.id,
      body: annotation.body,
      at: annotation.at,
      # The render_one function provides conveniences such as handling possible nil results.
      # 参数名字是从view的名字得到 UserView -> %{user: user}
      user: render_one(annotation.user, RumblWeb.UserView, "user.json")
    }
  end
end
