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

  it 'passes an xml document to Tracker.handle_activity' do
    post "/pivotal-tracker", Fixtures.create_story_xml

    app.pivotal_tracker_service.messages.must_equal [:handle_activity]
    app.pivotal_tracker_service.data.flatten.first.must_be_instance_of Nokogiri::XML::Document
  end
end

  # def test_cumulative_flow_endpoint
  #   get "/cfd"
  #   assert last_response.ok?

  #   assert_equal CumulativeFlow.report.to_json, last_response.body
  # end

  # # model tests
  # # what an astronomical mess!
  # def test_cumulative_flow_report
  #   # TODO 2013/06/21
  #   # need to test support for multiple dates/keys
  #   # add logic to import process to get accurate start/end dates
  #   # for histories, e.g. when was it accepted as start_date...
  #   counts = {
  #     icebox:    7,
  #     backlog:   14,
  #     started:   2,
  #     finished:  1,
  #     delivered: 1,
  #     accepted:  41,
  #     rejected:  1
  #   }.sort

  #   expected = { "2013-06-20" => Hash[counts] }

  #   assert_equal expected, CumulativeFlow.report
  # end

  # def test_cumulative_flow_to_hash
  #   expected = { foxy: 3 }
  #   assert_equal expected, CumulativeFlow.new(description: "foxy", count: 3).to_hash
  # end


  # def test_closing_history_when_none_exists
  #   assert close_history()
  # end

  # def test_closing_history_when_no_status_change
  #   # have history, no state change
  # end

  # def test_closing_history_when_changing_status
  #   # have history, changing to a new state
  # end

# Possible Pivotal Tracker State Changes:
#
# new story
# estimate added to story
# icebox -> backlog (unscheduled -> scheduled)
# icebox -> current (unscheduled -> started)
# backlog -> current (unstarted -> started)
# started -> unstarted (current -> backlog)
# started -> finished
# finished -> delivered
# delivered -> rejected
# rejected -> started
#
