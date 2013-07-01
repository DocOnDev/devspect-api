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

  # def test_import_activity
  #   # this test sucks
  #   xml = Nokogiri::XML(File.read("pivotal.xml"))
  #   assert_equal(nil, import_activity(xml))
  # end

  # def test_parsing_id_and_status
  #   xml = Nokogiri::XML(File.read("pivotal.xml"))
  #   assert_equal [109, "accepted"], parse_id_and_status(xml)
  # end

  # def test_close_history_predicate_returns_false_when_history_is_nil
  #   refute close_history?(nil, 1)
  # end

  # def test_close_history_predicate_returns_false_when_status_ids_match
  #   history = StoryHistory.new(status_id: 1)
  #   refute close_history?(history, 1)
  # end

  # def test_close_history_predicate_returns_true_when_status_ids_do_not_match
  #   history = StoryHistory.new(status_id: 1)
  #   assert close_history?(history, 2)
  # end

  # def test_create_history_attrs_makes_a_hash_of_history_attributes
  #   actual = history_attrs_for(1, 2)
  #   assert_equal 1, actual[:story_id]
  #   assert_equal 2, actual[:status_id]
  # end

  # def test_create_history_predicate_returns_false_when_valid_history_exists
  #   h = StoryHistory.new(history_attrs_for(1, 2)).save
  #   refute create_history?(1, 2)
  #   h.delete
  # end

  # def test_create_history_predicate_returns_true_when_no_history_exists
  #   attrs = { story_id: 1, status_id: 2 }
  #   h = StoryHistory.find(attrs)
  #   h && h.delete
  #   assert create_history?(1, 2)
  # end

end
