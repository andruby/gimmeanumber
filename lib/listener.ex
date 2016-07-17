defmodule Gimmeanumber.Listener do
  @botname Application.get_env(:gimmeanumber, :botname)

  def start_stream(server) do
    IO.puts "Listening to tweets to @#{@botname}"
    stream = ExTwitter.stream_user()
    for tweet <- stream do
      handle_event(server, tweet)
    end
  end

  defp handle_event(_server, %ExTwitter.Model.Tweet{user: %ExTwitter.Model.User{screen_name: @botname}}) do
    IO.puts "Ignore tweets from myself"
  end

  defp handle_event(server, %ExTwitter.Model.Tweet{id: tweet_id, user: %ExTwitter.Model.User{screen_name: screen_name}}) do
    IO.puts("Incoming tweet from #{screen_name}")
    Gimmeanumber.Worker.reply(server, [tweet_id: tweet_id, screen_name: screen_name])
  end

  defp handle_event(_server, event) do
    IO.puts "Unhandled event:"
    IO.inspect(event)
  end
end
