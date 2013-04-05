require 'rspec/core/rake_task'
require 'simplecov'

RSpec::Core::RakeTask.new(:spec) do |t|
  require File.expand_path("../../../config/environment", __FILE__)
  require './spec/spec_helper'
  if ENV['COVERAGE']
    SimpleCov.start do
      add_filter 'spec'
      add_group "Models", "models"
      add_group "Controllers", "controllers"
      add_group "Libraries", "lib"
    end
  end
end