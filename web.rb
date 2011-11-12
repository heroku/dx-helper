require "json"
require "sinatra"
require "tinder"

$stdout.sync = true

class Web < Sinatra::Application

  get "/" do
    "DX Helper"
  end

  post "/travis" do
    payload = JSON.parse(params[:payload])

    puts payload.inspect

    message = "[%s/%s] ci %s - %s - %s" % [
      payload["repository"]["name"],
      payload["branch"],
      fancy_status_message(payload),
      payload["author_name"],
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

  def fancy_status_message(payload)
    case payload["status_message"].downcase
      when "passed" then "passed"
      else "FAILED"
    end
  end

  def room
    tinder = Tinder::Campfire.new(ENV["CAMPFIRE_SUBDOMAIN"], :token => ENV["CAMPFIRE_TOKEN"])
    room = tinder.rooms.detect { |r| r.name == ENV["CAMPFIRE_ROOM"] }
  end

end
