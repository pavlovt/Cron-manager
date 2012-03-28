# encoding: utf-8

require 'rubygems'
require 'active_record'
require 'yaml'

App = "#{Base}/app"

require "#{App}/helpers/application_helper.rb"

# DB Connect 
dbconfig = YAML::load(File.open("#{Base}/config/database.yml"))
ActiveRecord::Base.establish_connection(dbconfig['development'])

# Load all models
Dir["#{App}/models/*.rb"].each{ |f| require f }