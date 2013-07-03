require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

class FakeModel
  @@instances = []
  attr_reader :messages, :data

  def initialize(*args)
    @messages = []
    @data = []
    @@instances << self
  end

  def self.last_instance
    @@instances.last
  end

  def method_missing(method_id, *attrs)
    @messages << method_id
    @data << attrs
  end
end

class Fixtures
  def self.create_story_xml(story_id=1234)
    %Q{
      <?xml version="1.0" encoding="UTF-8"?>
      <activity>
        <id type="integer">381300435</id>
        <version type="integer">585</version>
        <event_type>story_create</event_type>
        <occurred_at type="datetime">#{ timestamp }</occurred_at>
        <author>Cory Flanigan</author>
        <project_id type="integer">707539</project_id>
        <description>Cory Flanigan added &quot;Test story to determine cause of webhook bug&quot;</description>
        <stories type="array">
          <story>
            <id type="integer">#{ story_id }</id>
            <url>http://www.pivotaltracker.com/services/v3/projects/707539/stories/#{story_id}</url>
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

  def self.update_estimate_xml(story_id=1234)
    %Q{
      <?xml version="1.0" encoding="UTF-8"?>
      <activity>
        <id type="integer">381296099</id>
        <version type="integer">583</version>
        <event_type>story_update</event_type>
        <occurred_at type="datetime">#{ timestamp }</occurred_at>
        <author>Cory Flanigan</author>
        <project_id type="integer">707539</project_id>
        <description>Cory Flanigan estimated &quot;Create story from Tracker endpoint webhook call if one does not exist&quot; as 3 points</description>
        <stories type="array">
          <story>
            <id type="integer">#{ story_id }</id>
            <url>http://www.pivotaltracker.com/services/v3/projects/707539/stories/#{ story_id }</url>
            <estimate type="integer">3</estimate>
          </story>
        </stories>
      </activity>
    }
  end

  def self.update_description_xml(story_id=1234)
    %Q{
      <activity>
        <id type="integer">382622803</id>
        <version type="integer">634</version>
        <event_type>story_update</event_type>
        <occurred_at type="datetime">#{ timestamp }</occurred_at>
        <author>Cory Flanigan</author>
        <project_id type="integer">707539</project_id>
        <description>Cory Flanigan edited &quot;Capture state changes for Points estimate&quot;</description>
        <stories type="array">
          <story>
            <id type="integer">#{ story_id }</id>
            <url>http://www.pivotaltracker.com/services/v3/projects/707539/stories/#{ story_id }</url>
            <description>Not exactly sure what this story means anymore.</description>
          </story>
        </stories>
      </activity>
    }
  end

  def self.update_current_state_xml(story_id=1234)
    %Q{
      <?xml version="1.0" encoding="UTF-8"?>
      <activity>
        <id type="integer">381307107</id>
        <version type="integer">588</version>
        <event_type>story_update</event_type>
        <occurred_at type="datetime">#{ timestamp }</occurred_at>
        <author>Cory Flanigan</author>
        <project_id type="integer">707539</project_id>
        <description>Cory Flanigan edited &quot;Capture state changes for Points estimate&quot;</description>
        <stories type="array">
          <story>
            <id type="integer">#{ story_id }</id>
            <url>http://www.pivotaltracker.com/services/v3/projects/707539/stories/#{ story_id }</url>
            <current_state>unstarted</current_state>
          </story>
        </stories>
      </activity>
    }
  end

  def self.create_story_hash(story_id=1234)
    { "event_type"    => "story_create",
      "occurred_at"   => DateTime.parse(Fixtures.timestamp),
      "project_id"    => 707539,
      "story"         =>
        { "id"            => story_id,
          "url"           => "http://www.pivotaltracker.com/services/v3/projects/707539/stories/#{ story_id }",
          "name"          => "Test story to determine cause of webhook bug",
          "story_type"    => "feature",
          "description"   => "Does this give us different xml?",
          "estimate"      => 2,
          "current_state" => "unscheduled",
          "owned_by"      => "Cory Flanigan",
          "requested_by"  => "Cory Flanigan"
        }
    }
  end

  def self.update_estimate_hash(story_id=1234)
    { "event_type"    => "story_update",
      "occurred_at"   => DateTime.parse(Fixtures.timestamp),
      "project_id"    => 707539,
      "story"         =>
        { "id"            => story_id,
          "url"           => "http://www.pivotaltracker.com/services/v3/projects/707539/stories/#{ story_id }",
          "estimate"      => 3
        }
    }
  end

  def self.update_current_state_hash(story_id=1234)
    { "event_type"    => "story_update",
      "occurred_at"   => DateTime.parse(Fixtures.timestamp),
      "project_id"    => 707539,
      "story"         =>
        { "id"            => 1234,
          "url"           => "http://www.pivotaltracker.com/services/v3/projects/707539/stories/1234",
          "current_state" => "unstarted"
        }
    }
  end

  def self.timestamp
    "2013/07/04 12:00:00 UTC"
  end
end
