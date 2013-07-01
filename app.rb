require 'bundler'
require 'bundler/setup'
require 'json'
require 'sequel'
require 'sinatra'
require 'nokogiri'

require_relative 'tracker'

DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost:5432/devspect-api')

class Story        < Sequel::Model(:pivotal_tracker_stories)
  unrestrict_primary_key # are we sure we want this?
  def self.create_story(attrs)
    new(attrs).save
  end
end

class Project      < Sequel::Model(:pivotal_tracker_projects); end
class StoryStatus  < Sequel::Model(:pivotal_tracker_story_statuses); end
class StoryHistory < Sequel::Model(:pivotal_tracker_story_histories); end

class CumulativeFlow < Sequel::Model(:cfd_summary)
  STATUS_MAP = { icebox:    "unscheduled",
                 backlog:   "unstarted" }

  def self.statuses
    @statuses ||= StoryStatus.order(:position).select_map(:description).map do |desc|
      self.hash_key_for(desc)
    end
  end

  def self.default_counts
    @default_counts ||= statuses.each_with_object({}) {|s, hsh| hsh[s] = 0 }
  end

  def self.report
    self.order(:status_date).all.each_with_object(Hash.new({})) do |d, hsh|
      key = d.status_date.strftime("%Y-%m-%d")
      old_value = hsh[key]
      new_value = default_counts.merge(old_value).merge(d.to_hash)
      hsh[key] = Hash[new_value]
    end
  end

  def self.report_for_node_frontend
    report_results = report
    statuses.each_with_object([]) do |status, output|
      output << {
        name: status,
        data: report_results.map do |day, counts|
          [DateTime.parse(day).to_time.to_i * 1000, counts[status]]
        end
      }
    end
  end

  def to_hash
    @hash ||= { self.class.hash_key_for(self.description) => self.count }
  end

  private
  def self.hash_key_for(description)
    STATUS_MAP.invert[description] || description.to_sym
  end
end

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
