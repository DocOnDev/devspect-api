CREATE TABLE pivotal_tracker (
  id SERIAL PRIMARY KEY,
  author_name CHARACTER VARYING,
  description CHARACTER VARYING,
  occurred_at TIMESTAMP WITH TIME ZONE,
  activity_type CHARACTER VARYING,
  project_id INTEGER
);
