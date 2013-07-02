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
      "start_date"    => created_at,
      "current_state" => "unscheduled",
      "story_id"      => story_id
    }

    self.story_model.create_story(story_attrs)
    self.history_model.create_history(history_attrs)
  end

  # def import_activity(doc)
  #   story_id, current_status = parse_id_and_status(doc)

  #   story_status = StoryStatus.find(description: current_status)
  #   return unless story_status

  #   new_status_id   = story_status.id
  #   current_history = StoryHistory.find(story_id: story_id, end_date: nil)

  #   # probably need to wrap this in a txn
  #   if close_history?(current_history, new_status_id)
  #     close_history(current_history) 
  #   end

  #   attrs = history_attrs_for(story_id, new_status_id)
  #   StoryHistory.new(attrs).save if create_history?(story_id, new_status_id)
  # end

  # def parse_id_and_status(doc)
  #   [(doc / "story/id").text.to_i, (doc / "current_state").text]
  # end

  # def close_history?(history, new_status_id)
  #   history && history.status_id != new_status_id
  # end

  # def close_history(history)
  #   history.update(end_date: Time.now)
  # end

  # def history_attrs_for(story_id, status_id)
  #   { story_id: story_id, start_date: Time.now, status_id: status_id }
  # end

  # def create_history?(story_id, status_id)
  #   attrs = { story_id: story_id, status_id: status_id }
  #   history = StoryHistory.find(attrs)
  #   return false if history && !close_history?(history, status_id)
  #   true
  # end

  # def parse_story_attributes
  # end
end
