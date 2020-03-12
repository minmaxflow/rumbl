defmodule Rumbl.Multimedia.Video do
  use Ecto.Schema
  import Ecto.Changeset

  # 在代码内部使用单数
  # 在外部边界 table/url使用复数
  @primary_key {:id, Rumbl.Multimedia.Permalink, autogenerate: true}
  schema "videos" do
    field :description, :string
    field :title, :string
    field :url, :string
    field :slug, :string

    belongs_to :user, Rumbl.Accounts.User
    belongs_to :category, Rumbl.Multimedia.Category

    timestamps()
  end

  # The :user_id field is neither castable nor required in the previous example, 
  # because many times the field doesn’t come from external data such as forms but, rather, directly from the application.
  # user_id都是通过put_assoc这种方式类，所以没必要在cast里面标记 
  #   video |> Changeset.change() |> Changeset.put_assoc(​:user​, user)
  #   Changeset.put_change(​:user_id​, user.id) 
  # 如果是手动放入attrs，则应该在cast里面进行标记, 比如category_id
  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:url, :title, :description, :category_id])
    |> validate_required([:url, :title, :description])
    |> assoc_constraint(:category)
    |> slugify_title()
  end

  defp slugify_title(changeset) do
    case fetch_change(changeset, :title) do
      {:ok, new_title} -> put_change(changeset, :slug, slugify(new_title))
      :error -> changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end
end

# mix phx.gen.html Multimedia Video videos user_id:references:users url:string title:string description:text
# mix phx.gen.json 

# mix phx.gen.html Multimedia Category categories name:string 
# mix phx.gen.context Multimedia Category categories name:string
# mix phx.gen.schema Multimedia.Category categories name:string // 不需要提供contenxt了
# mix ecto.gen.migration create_categories

# 处理delete的方式以及添加数据时候的constraint的处理

# ​ 	​iex>​ alias Rumbl.Repo
# ​ 	​iex>​ alias Rumbl.Multimedia.Category
# ​ 	
# ​ 	​iex>​ category = Repo.get_by(Category, ​name:​ ​"​​Drama"​)
# ​ 	%Rumbl.Multimedia.Category{...}
# ​ 	
# ​ 	​iex>​ Repo.delete(category)
# ​ 	​**​ (Ecto.ConstraintError) constraint error when attempting to delete
# ​ 	struct”

# 方法1 
# you could configure the database references to either cascade the deletions or simply make the videos.category_id columns NULL on delete. Let’s open up the add_category_id_to_video migration:
# ​ add ​:category_id​, references(​:categories​)
#     references(:categories, on_delete: :nothing)
#      :nothing 阻止删除
#      :delete_all 一起删除
#      :nilify_all  set category_id to null 

# 方法2 
# Repo.delete also accepts a changeset, and you can use foreign_key_constraint to ensure that no associated videos exist when a category is deleted; 
# otherwise you get a nice error message. The foreign_key_constraint function is like the assoc_constraint we used earlier, 
# except it doesn’t inflect the foreign key from the relationship. This is particularly useful when you want to show the user why you can’t delete the category:

# This time, we had to be a bit more explicit in the foreign_key_constraint call, because the foreign key has been set in the videos table. If needed, we could also add no_assoc_constraint to do the dirty work of lifting up the foreign-key name and setting a good error message.

# ​ 	​iex>​ ​import​ Ecto.Changeset
# ​ 	​iex>​ changeset = change(category)
# ​ 	​iex>​ changeset = foreign_key_constraint(changeset, ​:videos​,
# ​ 	  name: :videos_category_id_fkey, message: "still exist")
# ​ 	
# ​ 	​iex>​ Repo.delete(changeset)
# ​ 	{:error,
# ​ 	 #Ecto.Changeset<
# ​ 	   ...,
# ​ 	   errors: [videos: {"still exist", []}],
# ​ 	   valid?: false
# ​ 	 >}

# 方法3 let it crash 
# 不需要所有的都加上 _constraint, 因为有的情况报错给用户没有任何意义(有意义的情况：用户重新选择一个分类)，这个时候let it crash

# Phoenix allows us to convert them into nice status pages. Furthermore, we also recommend setting up a notification system that aggregates and emails errors coming from your application, so you can discover and act on potential bugs when your software is running in production.
# Putting it another way: the *_constraint changeset functions are useful when the constraint being mapped is triggered by external data, often as part of the user request. Using changeset constraints only makes sense if the error message can be something the user can take action on.

# assoc is another convenient function from Ecto that returns an Ecto.Query with the user scoped to the given video.
# query = Ecto.assoc(video, ​:user​)
# ​ 	​iex>​ Repo.all from v ​in​ Video,
# ​ 	​...>​          ​join:​ u ​in​ assoc(v, ​:user​),
# ​ 	​...>​          ​join:​ c ​in​ assoc(v, ​:category​),
# ​ 	​...>​          ​where:​ c.name == ​"​​Comedy"​,
# ​ 	​...>​          ​select:​ {u, v}
