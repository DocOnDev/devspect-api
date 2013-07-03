require 'bundler'
require 'bundler/setup'
require 'json'
require 'sequel'
require 'sinatra'
require 'nokogiri'

require_relative 'models'
require_relative 'lib/tracker'

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

  def self.parse_tracker_xml(xml)
    doc = Nokogiri::XML(xml)
    { "event_type"    => get_attr(doc, "event_type"),
      "occurred_at"   => DateTime.parse(get_attr(doc, "occurred_at")),
      "project_id"    => get_attr(doc, "project_id").to_i,
      "story"         =>
        { "id"            => get_attr(doc, "story/id").to_i,
          "url"           => get_attr(doc, "story/url"),
          "name"          => get_attr(doc, "story/name"),
          "story_type"    => get_attr(doc, "story/story_type"),
          "description"   => get_attr(doc, "story/description"),
          "estimate"      => get_attr(doc, "story/estimate").to_i,
          "current_state" => get_attr(doc, "story/current_state"),
          "owned_by"      => get_attr(doc, "story/owned_by"),
          "requested_by"  => get_attr(doc, "story/requested_by")
      }.reject {|k, v| v.to_s.empty? }
    }
  end

  def self.get_attr(doc, attr)
    (doc / attr).text
  end
end
