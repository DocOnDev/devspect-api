require_relative 'spec_helper'

require 'time'
require 'nokogiri'
require_relative 'tracker'

describe Tracker do
  it 'creates a story' do
    tracker.handle_activity(xml_doc)

    fake_story.messages.must_equal     [:create_story]
    fake_story.data.flatten.must_equal [story_attrs]
  end

  it 'creates a history record on story creation' do
    tracker.handle_activity(xml_doc)

    fake_history.messages.must_equal     [:create_history]
    fake_history.data.flatten.must_equal [history_attrs]
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

  def xml_doc
    doc = Nokogiri::XML(Fixtures.create_story_xml)
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
end
