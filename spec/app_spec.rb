require_relative 'spec_helper'

require './app'
require 'rack'
require 'rack/test'

set :environment, :test

describe 'devspect-api' do
  include Rack::Test::Methods

  def app
    DevSpectAPI
  end

  before do
    DevSpectAPI.pivotal_tracker_service = FakeModel.new
  end

  it 'responds to /' do
    get "/"

    last_response.ok?.must_equal true
    last_response.body.must_equal "hello sinatra"
  end

  it 'responds to /pivotal-tracker' do
    post "/pivotal-tracker", Fixtures.create_story_xml

    last_response.ok?.must_equal true
    last_response.body.must_equal "OK"
  end

  it 'passes a hash to Tracker.handle_activity' do
    post "/pivotal-tracker", Fixtures.create_story_xml

    app.pivotal_tracker_service.messages.must_equal [:handle_activity]
    app.pivotal_tracker_service.data.flatten.first.must_equal Fixtures.create_story_hash
  end

  it 'parses xml from Pivotal Tracker into a hash' do
    xml = Fixtures.create_story_xml

    app.parse_tracker_xml(xml).must_equal Fixtures.create_story_hash
  end

  it 'returns a dense hash' do
    xml = Fixtures.update_estimate_xml

    app.parse_tracker_xml(xml).must_equal Fixtures.update_estimate_hash
  end

  it 'handles zero values' do
    xml = Fixtures.update_current_state_xml

    app.parse_tracker_xml(xml).must_equal Fixtures.update_current_state_hash
  end
end
