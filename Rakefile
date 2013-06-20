#!/usr/bin/env rake

desc "Reset db"
task :reset do
  system("dropdb devspect-api")
  system("createdb devspect-api")
  system("psql devspect-api -f schema.sql")
  system("ruby ./pivotal-tracker-data-import.rb")
end
