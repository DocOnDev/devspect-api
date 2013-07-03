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

  # change this test, it will pass a hash
  it 'passes an xml document to Tracker.handle_activity' do
    post "/pivotal-tracker", Fixtures.create_story_xml

    app.pivotal_tracker_service.messages.must_equal [:handle_activity]
    app.pivotal_tracker_service.data.flatten.first.must_be_instance_of Nokogiri::XML::Document
  end

  it 'parses xml from Pivotal Tracker into a hash' do
    xml = Fixtures.create_story_xml(1234)

    app.parse_tracker_xml(xml).must_equal Fixtures.create_story_hash(1234)
  end

  it 'returns a dense hash' do
    xml = Fixtures.update_estimate_xml(1234)

    app.parse_tracker_xml(xml).must_equal Fixtures.update_estimate_hash(1234)
  end

  it 'handles zero values' do
    xml = Fixtures.update_current_state_xml(1234)

    app.parse_tracker_xml(xml).must_equal Fixtures.update_current_state_hash(1234)
  end
end
