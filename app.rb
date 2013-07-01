require 'bundler'
require 'bundler/setup'
require 'json'
require 'sequel'
require 'sinatra'
require 'nokogiri'

require_relative 'models'
require_relative 'tracker'

class DevSpectAPI < Sinatra::Base
  class << self
    attr_accessor :pivotal_tracker_service
  end

  self.pivotal_tracker_service ||= Tracker.new(Story, StoryHistory)

  get '/' do
    "hello sinatra"
  end

  get '/cfd' do
    content_type :json
    # CumulativeFlow.report.to_json

    # how can we inject/mock/stub this so the test for it doesn't hit the db?
    CumulativeFlow.report_for_node_frontend.to_json
  end

  post '/pivotal-tracker' do
    require 'net/http'
    content_type :xml
    raw_tracker_xml = request.body.read
    remote_pastelog raw_tracker_xml

    self.class.pivotal_tracker_service.handle_activity(Nokogiri::XML(raw_tracker_xml))
    "OK"
  end

  def remote_pastelog(xml)
    http = Net::HTTP.new("requestb.in")
    request = Net::HTTP::Post.new("/10yl6iy1")
    request.body = xml
    http.request(request)
  end
end
