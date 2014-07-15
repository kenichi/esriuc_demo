require 'yaml'
require 'geotrigger'
require 'http'
require 'logger'

l = Logger.new STDOUT
l.level = Logger::INFO

DS_REFRESH_TOKEN = "replace me with your device's refresh token"

oauth = YAML.load_file 'app/geotrigger.yml'
s = Geotrigger::Session.new oauth
ds = Geotrigger::Session.new type: :device,
                             client_id: oauth[:client_id],
                             refresh_token: DS_REFRESH_TOKEN

rs = JSON.parse File.read 'record.json'

rs.each do |r|

  r['parameters']['locations'].each do |l|
    l['timestamp'] = Time.now.iso8601
  end

  l.debug "posting to GT..."
  ds.post 'location/update', r['parameters']

  l.debug "posting to esri.nakamura.io..."
  HTTP.post 'http://esri.nakamura.io/biker_loc',
    params: {
      latitude: r['parameters']['locations'].last['latitude'],
      longitude: r['parameters']['locations'].last['longitude']
    }

  l.debug "sleeping..."
  sleep r['timing'] / 20

end
