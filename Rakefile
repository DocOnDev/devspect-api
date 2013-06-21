#!/usr/bin/env rake

desc "Reset db"
task :reset do
  system("dropdb devspect-api")
  system("createdb devspect-api")
  system("psql devspect-api -f schema.sql")
  system("ruby ./pivotal_tracker_data_import.rb")
end
