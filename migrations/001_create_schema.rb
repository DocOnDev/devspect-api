require 'bundler'

Bundler.setup

require 'sequel'

Sequel.migration do
  up do
    create_table(:pivotal_tracker_activities) do
      primary_key :id
      String :author_name
      String :description
      DateTime :occurred_at
      String :activity_type
      Integer :project_id
      Integer :story_id
    end

    create_table(:pivotal_tracker_story_statuses) do
      primary_key :id
      String :description
    end

    create_table(:pivotal_tracker_story_histories) do
      primary_key :id
      DateTime :start_date
      DateTime :end_date
      Integer :status_id
      Integer :story_id
    end

    create_table(:pivotal_tracker_stories) do
      primary_key :id
      String :name
      DateTime :accepted_at
      DateTime :created_at
      Integer :deadline
      String :description
      Integer :estimate
      Integer :integration_id
      Integer :jira_id
      String :jira_url
      String :labels
      Integer :other_id
      String :owned_by
      Integer :project_id
      String :requested_by
      String :story_type
      String :url
    end

    create_table(:pivotal_tracker_projects) do
      primary_key :id
      String :owner
      Integer :current_iteration_number
      Integer :current_velocity
      DateTime :first_iteration_start_time
      Integer :initial_velocity
      Integer :iteration_length
      String :labels
      DateTime :last_activity_at
      String :name
      column :point_scale, 'INTEGER[]'
      String :velocity_scheme
      String :week_start_day
    end

    cfd_summary_sql = <<-sql
      SELECT date_trunc('day', h.start_date) AS status_date,
             a.description, sum(1)           AS count
      FROM pivotal_tracker_stories s INNER JOIN
           pivotal_tracker_story_histories h ON h.story_id = s.id INNER JOIN
           pivotal_tracker_story_statuses a ON a.id = h.status_id
      GROUP BY status_date,
               a.description
    sql

    create_or_replace_view(:cfd_summary, cfd_summary_sql)
  end
end
