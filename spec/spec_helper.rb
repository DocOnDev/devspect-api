require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'

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

  def self.update_story_xml
    %Q{
      <?xml version="1.0" encoding="UTF-8"?>
      <activity>
       <id type="integer">1031</id>
       <version type="integer">175</version>
       <event_type>story_update</event_type>
       <occurred_at type="datetime">2009/12/14 14:12:09 PST</occurred_at>
       <author>James Kirk</author>
       <project_id type="integer">26</project_id>
       <description>James Kirk accepted &quot;More power to shields&quot;</description>
       <stories>
         <story>
           <id type="integer">109</id>
           <url>https:///projects/26/stories/109</url>
           <accepted_at type="datetime">2009/12/14 22:12:09 UTC</accepted_at>
           <current_state>accepted</current_state>
         </story>
       </stories>
      </activity>
    }

  end

  def self.update_estimate_xml
    %Q{
      <?xml version="1.0" encoding="UTF-8"?>
      <activity>
        <id type="integer">381296099</id>
        <version type="integer">583</version>
        <event_type>story_update</event_type>
        <occurred_at type="datetime">2013/07/01 17:36:43 UTC</occurred_at>
        <author>Cory Flanigan</author>
        <project_id type="integer">707539</project_id>
        <description>Cory Flanigan estimated &quot;Create story from Tracker endpoint webhook call if one does not exist&quot; as 3 points</description>
        <stories type="array">
          <story>
            <id type="integer">52569461</id>
            <url>http://www.pivotaltracker.com/services/v3/projects/707539/stories/52569461</url>
            <estimate type="integer">3</estimate>
          </story>
        </stories>
      </activity>
    }
  end
end
