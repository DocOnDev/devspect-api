require './app'
require 'minitest/autorun'
require 'minitest/pride'
require 'rack'
require 'rack/test'

set :environment, :test

class IntegrationTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_creating_a_story
    tracker_xml <<-xml
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
            <current_state>unscheduled</current_state>
            <requested_by>Cory Flanigan</requested_by>
          </story>
        </stories>
      </activity>
    xml

    post '/pivotal-tracker'

    assert last_response.ok?
    assert_equal "OK", last_response.body
    assert # a story was created
  end

  def test_estimating_an_unestimated_story
    tracker_xml = <<-xml
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
    xml

    post "/pivotal-tracker", tracker_xml

    assert last_response.ok?
    assert_equal "OK", last_response.body
  end
end
