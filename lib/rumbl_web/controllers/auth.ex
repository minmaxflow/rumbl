defmodule RumblWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias RumblWeb.Router.Helpers, as: Routes

  alias Rumbl.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      # we choose to test our login mechanism in isolation and build a bypass mechanism for the rest of our test cases
      # 方便测试
      conn.assigns[:current_user] ->
        conn

      user = user_id && Accounts.get_user(user_id) ->
        assign(conn, :current_user, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    # drop whole session 
    configure_session(conn, drop: true)
    # only delete user_id 
    # delete_session(conn, :user_id)
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
