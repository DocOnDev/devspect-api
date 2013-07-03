require_relative 'spec_helper'

require 'nokogiri'
require_relative '../lib/tracker'

describe Tracker do
  it 'creates a story' do
    tracker.handle_activity(create_story_xml_doc)

    fake_story.messages.must_equal     [:create_story]
    fake_story.data.flatten.must_equal [story_attrs]
  end

  it 'creates a history record on story creation' do
    tracker.handle_activity(create_story_xml_doc)

    fake_history.messages.must_equal     [:create_history]
    fake_history.data.flatten.must_equal [history_attrs]
  end

  it 'updates a story when the estimate is changed' do
    tracker.handle_activity(update_estimate_xml_doc)

    fake_story.messages.must_equal     [:update_estimate]
    fake_story.data.flatten.must_equal [52569461, 3]
  end

  it 'updates status history when the current_state is changed' do
    tracker.handle_activity(update_current_state_xml_doc)

    fake_history.messages.must_equal     [:update_status_history]
    fake_history.data.flatten.must_equal [52652861, "unstarted"]
  end

  it 'event_type parses and returns the event type' do
    tracker.event_type(create_story_xml_doc).must_equal(:create_story)
    tracker.event_type(update_estimate_xml_doc).must_equal(:update_estimate)
    tracker.event_type(update_description_xml_doc).must_equal(:update_description)
    tracker.event_type(update_current_state_xml_doc).must_equal(:update_current_state)
  end

  def teardown
    @fake_story = nil
    @fake_history = nil
  end

  def tracker
    Tracker.new(fake_story, fake_history)
  end

  def fake_story
    @fake_story ||= FakeModel.new
  end

  def fake_history
    @fake_history ||= FakeModel.new
  end

  def create_story_xml_doc
    @create_story_doc ||= Nokogiri::XML(Fixtures.create_story_xml)
  end

  def update_estimate_xml_doc
    @update_estimate_doc ||= Nokogiri::XML(Fixtures.update_estimate_xml)
  end

  def update_description_xml_doc
    @update_description_doc ||= Nokogiri::XML(Fixtures.update_description_xml)
  end

  def update_current_state_xml_doc
    @update_current_state_xml_doc ||= Nokogiri::XML(Fixtures.update_current_state_xml)
  end

  def story_attrs
    { "id"            => 52651969,
      "name"          => "Test story to determine cause of webhook bug",
      "created_at"    => DateTime.parse("2013/07/01 17:42:51 UTC"),
      "description"   => "Does this give us different xml?",
      "estimate"      => 2,
      "story_type"    => "feature",
      "owned_by"      => "Cory Flanigan",
      "requested_by"  => "Cory Flanigan",
      "project_id"    => 707539
    }
  end

  def history_attrs
    { "start_date"    => DateTime.parse("2013/07/01 17:42:51 UTC"),
      "current_state" => "unscheduled",
      "story_id"      => 52651969,
    }
  end

  # def test_import_activity
  #   # this test sucks
  #   xml = Nokogiri::XML(File.read("pivotal.xml"))
  #   assert_equal(nil, import_activity(xml))
  # end

  # def test_parsing_id_and_status
  #   xml = Nokogiri::XML(File.read("pivotal.xml"))
  #   assert_equal [109, "accepted"], parse_id_and_status(xml)
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
end
