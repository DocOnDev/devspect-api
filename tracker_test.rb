require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'

require 'time'
require 'nokogiri'
require_relative 'tracker'

describe Tracker do
  it 'creates a story' do
    tracker.handle_activity(xml_doc)

    expected = [:create_story, story_attrs]

    fake_story.data.length.must_equal 1
    fake_story.data.first.must_equal expected
  end

  it 'creates a history record on story creation' do
    tracker.handle_activity(xml_doc)

    expected = [:create_history, history_attrs]

    fake_history.data.length.must_equal 1
    fake_history.data.first.must_equal  expected
  end

  def teardown
    @fake_story = nil
    @fake_history = nil
  end

  class FakeModel
    attr_reader :data

    def initialize
      @data = []
    end

    def method_missing(method_id, attrs)
      @data << [method_id, attrs]
    end
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
    doc = Nokogiri::XML(create_story_xml)
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

  def create_story_xml
    %Q{
<?xml version="1.0" encoding="UTF-8"?>
<activity>
  <id type="integer">381300435</id>
  <version type="integer">585</version>
  <event_type>story_create</event_type>
  <occurred_at type="datetime">2013/07/01 17:42:51 UTC</occurred_at>
  <author>Cory Flanigan</author>
  <project_id type="integer">707539</project_id>
  <description>Cory Flanigan added &quot;Test story to determine cause of webhook bug&quot;</description>
  <stories type="array">
    <story>
      <id type="integer">52651969</id>
      <url>http://www.pivotaltracker.com/services/v3/projects/707539/stories/52651969</url>
      <name>Test story to determine cause of webhook bug</name>
      <story_type>feature</story_type>
      <description>Does this give us different xml?</description>
      <estimate type="integer">2</estimate>
      <current_state>unscheduled</current_state>
      <owned_by>Cory Flanigan</owned_by>
      <requested_by>Cory Flanigan</requested_by>
    </story>
  </stories>
</activity>
    }
  end
end
