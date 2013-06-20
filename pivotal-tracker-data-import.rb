require 'bundler'

Bundler.setup

require 'pry'
require 'pivotal-tracker'
require 'sequel'

DB = Sequel.connect('postgres://localhost:5432/devspect-api')
stories  =        DB[:pivotal_tracker_stories]
projects =        DB[:pivotal_tracker_projects]
story_statuses =  DB[:pivotal_tracker_story_statuses]
story_histories = DB[:pivotal_tracker_story_histories]

PivotalTracker::Client.token = '8b2ba20d2a1b4d4309a4868d62f53e7a'
PivotalTracker::Client.use_ssl = true

project = PivotalTracker::Project.find(707539)

# PivotalTracker::Project.all.each do |project|
projects.insert(
  id:                         project.id,
  owner:                      project.account,
  current_iteration_number:   project.current_iteration_number,
  current_velocity:           project.current_velocity,
  first_iteration_start_time: project.first_iteration_start_time,
  initial_velocity:           project.initial_velocity,
  iteration_length:           project.iteration_length,
  labels:                     project.labels,
  last_activity_at:           project.last_activity_at,
  name:                       project.name,
  point_scale:                "{#{project.point_scale}}",
  velocity_scheme:            project.velocity_scheme,
  week_start_day:             project.week_start_day
)

project.stories.all.each do |story|
  class StoryStatus < Sequel::Model(:pivotal_tracker_story_statuses)
  end

  stories.insert(
    id:                story.id,
    name:              story.name,
    accepted_at:       story.accepted_at,
    created_at:        story.created_at,
    deadline:          story.deadline,
    description:       story.description,
    estimate:          story.estimate,
    integration_id:    story.integration_id,
    jira_id:           story.jira_id,
    jira_url:          story.jira_url,
    labels:            story.labels,
    other_id:          story.other_id,
    owned_by:          story.owned_by,
    project_id:        story.project_id,
    requested_by:      story.requested_by,
    story_type:        story.story_type,
    url:               story.url
  )

  current_status_id = StoryStatus.find_or_create(description: story.current_state).id

  story_histories.insert(
    start_date: Time.now, # local?
    status_id:  current_status_id,
    story_id:   story.id
  )
end
