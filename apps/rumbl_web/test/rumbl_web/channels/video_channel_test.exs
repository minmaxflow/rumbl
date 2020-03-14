#---
# Excerpted from "Programming Phoenix 1.4",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/phoenix14 for more book information.
#---
defmodule RumblWeb.Channels.VideoChannelTest do
  use RumblWeb.ChannelCase
  import RumblWeb.TestHelpers

  setup do 
    user = insert_user(name: "Gary") 
    video = insert_video(user, title: "Testing")
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)
    {:ok, socket} = connect(RumblWeb.UserSocket, %{"token" => token})

    {:ok, socket: socket, user: user, video: video}
  end

  test "join replies with video annotations", 
       %{socket: socket, video: vid, user: user} do 
    for body <- ~w(one two) do 
      Rumbl.Multimedia.annotate_video(user, vid.id, %{body: body, at: 0})
    end
    {:ok, reply, socket} = subscribe_and_join(socket, "videos:#{vid.id}", %{})

    assert socket.assigns.video_id == vid.id
    assert %{annotations: [%{body: "one"}, %{body: "two"}]} = reply
  end

  test "inserting new annotations", %{socket: socket, video: vid} do
    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{vid.id}", %{})
    ref = push socket, "new_annotation", %{body: "the body", at: 0}
    assert_reply ref, :ok, %{}
    assert_broadcast "new_annotation", %{}
  end

  test "new annotations triggers InfoSys", %{socket: socket, video: vid} do
    insert_user(
      username: "wolfram", 
      password: "supersecret"
    )
      
    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{vid.id}", %{})
    
    ref = push socket, "new_annotation", %{body: "1 + 1", at: 123}
    assert_reply ref, :ok, %{}
    assert_broadcast "new_annotation", %{body: "1 + 1", at: 123}
    assert_broadcast "new_annotation", %{body: "2", at: 123}
  end
end
