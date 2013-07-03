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

    expected = {
      "event_type"    => "story_create",
      "occurred_at"   => DateTime.parse("2013/07/01 17:42:51 UTC"),
      "project_id"    => 707539,
      "story"         =>
        { "id"            => 1234,
          "url"           => "http://www.pivotaltracker.com/services/v3/projects/707539/stories/1234",
          "name"          => "Test story to determine cause of webhook bug",
          "story_type"    => "feature",
          "description"   => "Does this give us different xml?",
          "estimate"      => 2,
          "current_state" => "unscheduled",
          "owned_by"      => "Cory Flanigan",
          "requested_by"  => "Cory Flanigan"
        }
    }

    app.parse_tracker_xml(xml).must_equal expected
  end

  it 'returns a dense hash' do
    xml = Fixtures.update_estimate_xml(1234)

    expected = {
      "event_type"    => "story_update",
      "occurred_at"   => DateTime.parse("2013/07/01 17:36:43 UTC"),
      "project_id"    => 707539,
      "story"         =>
        { "id"            => 1234,
          "url"           => "http://www.pivotaltracker.com/services/v3/projects/707539/stories/1234",
          "estimate"      => 3,
        }
    }

    app.parse_tracker_xml(xml).must_equal expected
  end
end
