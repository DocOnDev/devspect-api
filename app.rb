# TODO:
#
# figure out how to get message expectations in tests
#
# insert a story if one does not exist
#
# determine if we need to keep old descriptions/titles as part of
# history
#
# queries to serve JSON hashes to client
# get /cfd-data, {}
# {accepted: Story.execute_sql("SELECT sum(accepted)" ...}
# Create SQL view in schema to serve aggregates? Create model to
# wrap view?
#
# support for GitHub webhooks

require 'bundler'

Bundler.setup

require 'pry'
require 'json'
require 'sequel'
require 'sinatra'
require 'nokogiri'

DB = Sequel.connect('postgres://localhost:5432/devspect-api')

class Story        < Sequel::Model(:pivotal_tracker_stories); end
class Project      < Sequel::Model(:pivotal_tracker_projects); end
class StoryStatus  < Sequel::Model(:pivotal_tracker_story_statuses); end
class StoryHistory < Sequel::Model(:pivotal_tracker_story_histories); end

class CumulativeFlow < Sequel::Model(:cfd_summary)
  STATUS_MAP = { icebox:    "unscheduled",
                 backlog:   "unstarted" }

  def to_hash
    @hash ||= { hash_key => self.count }
  end

  private
  def hash_key
    @hash_key ||= STATUS_MAP.invert[self.description] || self.description.to_sym
  end
end

get '/' do
  "hello sinatra"
end

get '/cfd' do
  cfd_hash.to_json
end

post '/pivotal-tracker' do
  content_type :xml
  import_activity Nokogiri::XML(request.body.read)
  "OK"
end

def cfd_hash
  # status_dates = summaries.map(&:status_date).uniq
  # counts = status_dates.map {|d| {d => summaries.select {|s| s.status_date.eql? d } } }
  CumulativeFlow.all.each_with_object(Hash.new({})) do |d, hsh|
    key = d.status_date.strftime("%Y-%m-%d")
    hsh[key] = hsh[key].merge(d.to_hash)
  end
end

#   { icebox:    data.find {|s| s.description.eql?("unscheduled") }.count,
#     backlog:   data.find {|s| s.description.eql?("unstarted") }.count,
#     started:   data.find {|s| s.description.eql?("started") }.count,
#     finished:  data.find {|s| s.description.eql?("finished") }.count,
#     delivered: data.find {|s| s.description.eql?("delivered") }.count,
#     accepted:  data.find {|s| s.description.eql?("accepted") }.count,
#     rejected:  data.find {|s| s.description.eql?("rejected") }.count }
# end

def import_activity(doc)
  story_id, current_status = parse_id_and_status(doc)
  new_status_id            = StoryStatus.find(description: current_status).id

  current_history = StoryHistory.find(story_id: story_id, end_date: nil)

  # probably need to wrap this in a txn
  if close_history?(current_history, new_status_id)
    close_history(current_history) 
  end

  attrs = history_attrs_for(story_id, new_status_id)
  StoryHistory.new(attrs).save if create_history?(story_id, new_status_id)
end

def parse_id_and_status(doc)
  [(doc / "story/id").text.to_i, (doc / "current_state").text]
end

def close_history?(history, new_status_id)
  history && history.status_id != new_status_id
end

def close_history(history)
  history.update(end_date: Time.now)
end

def history_attrs_for(story_id, status_id)
  { story_id: story_id, start_date: Time.now, status_id: status_id }
end

def create_history?(story_id, status_id)
  attrs = { story_id: story_id, status_id: status_id }
  history = StoryHistory.find(attrs)
  return false if history && !close_history?(history, status_id)
  true
end
