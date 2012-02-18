require "json"
require "rest_client"
require "sinatra"
require "tinder"

$stdout.sync = true

class Web < Sinatra::Application

  get "/" do
    "DX Helper"
  end

  post "/notify" do
    if params[:service] && params[:message]
      notify_dx params[:service], params[:message]
    else
      "Use 'service' and 'message' parameters"
    end
  end

  post "/travis" do
    payload = JSON.parse(params[:payload])

    log "travis", payload, :ignore => %w( config matrix repository )

    message = "[%s/%s] %s %s ( %s )" % [
      payload["repository"]["name"],
      payload["branch"],
      fancy_status_message(payload),
      payload["author_name"],
      build_url(payload)
    ]

    notify_dx "travis", message

    "ok"
  end

  post "/zendesk" do
    payload = params[:payload]
    notify_dx "zendesk", payload
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
      when "passed" then "[PASS]"
      when "fixed"  then "[PASS]"
      else               "[FAIL]"
    end
  end

  def log(name, attrs, opts={})
    keys = attrs.keys.sort
    keys.reject! { |k| (opts[:ignore] || []).include?(k) }
    flattened = keys.map { |k| "#{k}=\"#{attrs[k]}\"" }.join(" ")
    puts "#{name} #{flattened}"
  end

  def campfire
    tinder = Tinder::Campfire.new(ENV["CAMPFIRE_SUBDOMAIN"], :token => ENV["CAMPFIRE_TOKEN"])
    tinder.rooms.detect { |r| r.name == ENV["CAMPFIRE_ROOM"] }
  end

  def grove
    @grove ||= RestClient::Resource.new("https://grove.io/api/notice/#{ENV["GROVE_TOKEN"]}/")
  end

  def notify_dx(service, message)
    full_message = "[%s] %s" % [ service, message ]
    campfire.speak full_message
    grove.post :service => service, :message => message
    full_message
  end

end
