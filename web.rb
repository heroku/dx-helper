require "json"
require "sinatra"
require "tinder"

class Web < Sinatra::Application

  get "/" do
    "DX Helper"
  end

  post "/travis" do
    payload = JSON.parse(request.body.read)

    message = "[%s/%s] ci %s - %s - %s" % [
      payload["repository"]["name"],
      payload["branch"],
      payload["status_message"].downcase,
      payload["committer_name"],
      build_url(payload)
    ]

    room.speak message

    "ok"
  end

protected

  def build_url(payload)
    "http://travis-ci.org/#!/%s/%s/builds/%s" % [
      payload["repository"]["owner_name"],
      payload["repository"]["name"],
      payload["id"]
    ]
  end

  def room
    tinder = Tinder::Campfire.new(ENV["CAMPFIRE_SUBDOMAIN"], :token => ENV["CAMPFIRE_TOKEN"])
    room = tinder.rooms.detect { |r| r.name == ENV["CAMPFIRE_ROOM"] }
  end

end
