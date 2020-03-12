defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  alias Rumbl.{Accounts, Multimedia}

  alias RumblWeb.AnnotationView

  # Remember, sockets will hold all of the state for a given conversation. 
  # Each socket can hold its own state in the socket.assigns field, which typically holds a map
  def join("videos:" <> video_id, params, socket) do
    send(self(), :after_join)

    last_seen_id = params["last_seen_id"] || 0
    video_id = String.to_integer(video_id)
    video = Multimedia.get_video!(video_id)

    annotations =
      video
      |> Multimedia.list_annotations(last_seen_id)
      |> Phoenix.View.render_many(AnnotationView, "annotation.json")

    {:ok, %{annotations: annotations}, assign(socket, :video_id, video_id)}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", RumblWeb.Presence.list(socket))

    {:ok, _} =
      RumblWeb.Presence.track(
        socket,
        socket.assigns.user_id,
        %{device: "browser"}
      )

    {:noreply, socket}
  end

  def handle_in(event, params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_annotation", params, user, socket) do
    case Multimedia.annotate_video(user, socket.assigns.video_id, params) do
      # 注意，并没有preload user,所以有一部分需要手动构造
      {:ok, annotation} ->
        broadcast!(socket, "new_annotation", %{
          id: annotation.id,
          user: RumblWeb.UserView.render("user.json", %{user: user}),
          body: annotation.body,
          at: annotation.at
        })

        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end

# Handling Disconnects
# Any stateful conversation between a client and server must handle data that gets out of sync. 
# This problem can happen with unexpected disconnects, or a broadcast that isn’t received while a client is away.

# 浏览器重新链接的时候要注意浏览器已有的状态，避免重复发送数据
# last_seen_id 
