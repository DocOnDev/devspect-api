class Tracker
  require 'time'

  attr_reader :story_model, :history_model

  def initialize(story_model, history_model)
    @story_model   = story_model
    @history_model = history_model
  end

  def handle_activity(activity)
    if event_type(activity).eql?(:create_story)
      story_id    = (activity / "story/id").text.to_i
      created_at  = DateTime.parse((activity / "occurred_at").text)

      story_attrs = {
        "id"            => story_id,
        "name"          => (activity / "story/name").text,
        "created_at"    => created_at,
        "description"   => (activity / "story/description").text,
        "estimate"      => (activity / "story/estimate").text.to_i,
        "story_type"    => (activity / "story/story_type").text,
        "owned_by"      => (activity / "story/owned_by").text,
        "requested_by"  => (activity / "story/requested_by").text,
        "project_id"    => (activity / "project_id").text.to_i
      }

      history_attrs = {
        "start_date"    => created_at,
        "current_state" => "unscheduled",
        "story_id"      => story_id
      }

      self.story_model.create_story(story_attrs)
      self.history_model.create_history(history_attrs)

    elsif event_type(activity).eql?(:update_estimate)
      story_id = (activity / "story/id").text.to_i
      estimate = (activity / "story/estimate").text.to_i

      self.story_model.update_estimate(story_id, estimate)
    elsif event_type(activity).eql?(:update_current_state)
      new_status = (activity / "story/current_state").text
      self.history_model.update_status_history(52652861, new_status)
    end
  end

  def event_type(activity)
    e = (activity / "event_type").text.gsub(/story_/, '')
    case e
    when "create" then :create_story
    when "update"
    then
       type = [:estimate, :description, :current_state].detect { |a|
         not (activity / "story/#{a}").text.empty?
       }
       :"update_#{ type }"
    end
  end
end

  # def import_activity(doc)
  #   story_id, current_status = parse_id_and_status(doc)

  #   story_status = StoryStatus.find(description: current_status)
  #   return unless story_status

  #   new_status_id   = story_status.id
  #   current_history = StoryHistory.find(story_id: story_id, end_date: nil)


  # def parse_id_and_status(doc)
  #   [(doc / "story/id").text.to_i, (doc / "current_state").text]
  # end

  # def parse_story_attributes
  # end
