DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost:5432/devspect-api')

class Story        < Sequel::Model(:pivotal_tracker_stories)
  unrestrict_primary_key # are we sure we want this?
  def self.create_story(attrs)
    new(attrs).save
  end
end

class Project      < Sequel::Model(:pivotal_tracker_projects); end
class StoryStatus  < Sequel::Model(:pivotal_tracker_story_statuses); end
class StoryHistory < Sequel::Model(:pivotal_tracker_story_histories)
  #   # probably need to wrap this in a txn
  #   if close_history?(current_history, new_status_id)
  #     close_history(current_history) 
  #   end

  #   attrs = history_attrs_for(story_id, new_status_id)
  #   StoryHistory.new(attrs).save if create_history?(story_id, new_status_id)
  # end
end

class CumulativeFlow < Sequel::Model(:cfd_summary)
  STATUS_MAP = { icebox:    "unscheduled",
                 backlog:   "unstarted" }

  def self.statuses
    @statuses ||= StoryStatus.order(:position).select_map(:description).map do |desc|
      self.hash_key_for(desc)
    end
  end

  def self.default_counts
    @default_counts ||= statuses.each_with_object({}) {|s, hsh| hsh[s] = 0 }
  end

  def self.report
    self.order(:status_date).all.each_with_object(Hash.new({})) do |d, hsh|
      key = d.status_date.strftime("%Y-%m-%d")
      old_value = hsh[key]
      new_value = default_counts.merge(old_value).merge(d.to_hash)
      hsh[key] = Hash[new_value]
    end
  end

  def self.report_for_node_frontend
    report_results = report
    statuses.each_with_object([]) do |status, output|
      output << {
        name: status,
        data: report_results.map do |day, counts|
          [DateTime.parse(day).to_time.to_i * 1000, counts[status]]
        end
      }
    end
  end

  def to_hash
    @hash ||= { self.class.hash_key_for(self.description) => self.count }
  end

  private
  def self.hash_key_for(description)
    STATUS_MAP.invert[description] || description.to_sym
  end
  # def close_history?(history, new_status_id)
  #   history && history.status_id != new_status_id                     end
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
