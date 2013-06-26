require 'bundler'
require 'bundler/setup'
require 'sequel'

Sequel.migration do
  change do
    drop_view(:cfd_summary)

    cfd_summary_sql = <<-sql
      SELECT d.day AS status_date,
        s.description,
        SUM(1) AS count
      FROM 
        (SELECT current_date - days.day AS day FROM generate_series(0,
          (SELECT CAST(EXTRACT(epoch FROM NOW() - DATE(MIN(start_date))) / 86400 AS integer) 
             FROM pivotal_tracker_story_histories)
             ,1) AS days(day)) d 
      INNER JOIN pivotal_tracker_story_histories h ON d.day
        BETWEEN h.start_date AND COALESCE(h.end_date, current_date)
      INNER JOIN pivotal_tracker_story_statuses s ON s.id = h.status_id
      GROUP BY d.day, s.description
      ORDER BY d.day, s.description;
    sql

    create_or_replace_view(:cfd_summary, cfd_summary_sql)
  end
end
