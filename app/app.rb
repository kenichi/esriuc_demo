require 'yaml'
require 'bundler'
Bundler.require
require 'angelo/tilt/erb'

class EsriUC < Angelo::Base
  include Angelo::Tilt::ERB

  before do
    @gt = Geotrigger::Application.new YAML.load_file 'geotrigger.yml'
  end

  get '/' do
    @trigger_list = @gt.post 'trigger/list', boundingBox: :geojson
    @host = 'esri.nakamura.io'
    erb :index
  end

  post '/trigger_callback' do
    msg = { triggerId: params['trigger']['triggerId'] }.to_json
    websockets.each do |ws|
      ws.write msg
    end
    ''
  end

  post '/biker_loc' do
    msg = {
      bikerLoc: {
        latitude: params['latitude'].to_f,
        longitude: params['longitude'].to_f
      }
    }.to_json
    websockets.each do |ws|
      ws.write msg
    end
    ''
  end

  websocket '/callbacks' do |ws|
    websockets << ws
  end

end

Devsummit.run
