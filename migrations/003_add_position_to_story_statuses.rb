require 'bundler'
require 'bundler/setup'
require 'sequel'

Sequel.migration do
  positions = %w{
    unscheduled
    unstarted
    started
    finished
    delivered
    rejected
    accepted
  }

  change do
    add_column :pivotal_tracker_story_statuses, :position, Integer
    positions.each_with_index do |p, i|
      from(:pivotal_tracker_story_statuses).
        where(description: p).
        update(position: i)
    end
  end
end
