# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Rumbl.Repo.insert!(%Rumbl.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Rumbl.Repo

alias Rumbl.Accounts
alias Rumbl.Accounts.User
alias Rumbl.Multimedia
alias Rumbl.Multimedia.Category

users = [
  %{name: "Jose", username: "josevalim", password: "temppass"},
  %{name: "Bruce", username: "redcapids", password: "tempass"},
  %{name: "Chris", username: "chrismccord", password: "tempass"}
]

# 按照道理应该先清除掉 用户再创建
# 但是由于在开发的时候外键约束没有设置好，导致需要先产出分类和视频，暂时先不动
for user <- users do
  Accounts.register_user(user)
end

for category <- ~w(Action Drama Romance Comedy Sci-fi) do
  Multimedia.create_category!(category)
end

{:ok, _} = Rumbl.Accounts.create_user(%{name: "Wolfram", username: "wolfram"})
