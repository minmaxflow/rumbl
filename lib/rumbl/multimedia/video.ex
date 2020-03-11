defmodule Rumbl.Multimedia.Video do
  use Ecto.Schema
  import Ecto.Changeset

  # 在代码内部使用单数
  # 在外部边界 table/url使用复数
  schema "videos" do
    field :description, :string
    field :title, :string
    field :url, :string

    belongs_to :user, Rumbl.Accounts.User
    belongs_to :category, Rumbl.Multimedia.Category

    timestamps()
  end

  # The :user_id field is neither castable nor required in the previous example, 
  # because many times the field doesn’t come from external data such as forms but, rather, directly from the application.
  # user_id都是通过put_assoc这种方式类，所以没必要在cast里面标记 
  #   video |> Changeset.change() |> Changeset.put_assoc(​:user​, user)
  #   Changeset.put_change(​:user_id​, user.id) 
  # 如果是手动放入attrs，则应该在cast里面进行标记
  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:url, :title, :description, :category_id])
    |> validate_required([:url, :title, :description])
  end

  # assoc is another convenient function from Ecto that returns an Ecto.Query with the user scoped to the given video.
  # query = Ecto.assoc(video, ​:user​)
end

# mix phx.gen.html Multimedia Video videos user_id:references:users url:string title:string description:text
# mix phx.gen.json 

# mix phx.gen.html Multimedia Category categories name:string 
# mix phx.gen.context Multimedia Category categories name:string
# mix phx.gen.schema Multimedia.Category categories name:string // 不需要提供contenxt了
# mix ecto.gen.migration create_categories
