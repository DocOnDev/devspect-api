class Tracker
  attr_reader :story_model, :history_model

  def initialize(story_model, history_model)
    @story_model   = story_model
    @history_model = history_model
  end

  def handle_activity(activity)
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
      # look up current_status_id from current_state in xml
      "start_date"    => created_at,
      "current_state" => "unscheduled",
      "story_id"      => story_id
    }

    self.story_model.create_story(story_attrs)
    self.history_model.create_history(history_attrs)
  end
end
