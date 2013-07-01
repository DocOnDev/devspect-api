require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'

class FakeModel
  attr_reader :messages, :data

  def initialize(*args)
    @messages = []
    @data = []
  end

  def method_missing(method_id, *attrs)
    @messages << method_id
    @data << attrs
  end
end

class Fixtures
  def self.create_story_xml
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
