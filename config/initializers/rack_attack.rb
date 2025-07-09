# config/initializers/rack_attack.rb (for rails apps)

Rack::Attack.throttle("requests by ip", limit: 1000, period: 60) do |request|
  request.ip
end


# Rack::Attack.blocklist_ip("1.2.0.0/16")
