require 'rubygems'
require 'bundler'
require_relative './modules/db.rb'

namespace :db do

  desc 'creates the mysql database'
  task :create do
    Tradenetic::DB.create_database
  end

  desc 'creates tables'
  task :tables => :create do
    Tradenetic::DB.create_tables
  end

  desc 'adds initial targets to database'
  task :targets => :tables do
    Tradenetic::DB.add_initial_targets
  end

  desc 'gets bars data'
  task :populate do
    Tradenetic::DB.populate
  end

end