# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Generate RBS files from inline annotations"
task :rbs do
  sh "rbs-inline --output sig lib"
end

desc "Run type checking with Steep"
task steep: :rbs do
  sh "steep check"
end

namespace :specs do
  desc "Download OpenAPI specs from Amazon Ads"
  task :download do
    require_relative "lib/generator/specs"
    Generator::Specs.download_all
  end
end

desc "Generate API classes from OpenAPI specs"
task :generate do
  require_relative "lib/generator/specs"
  require_relative "lib/generator/api"
  Generator::Specs::SPECS.each_key do |name|
    Generator::API.new(name.to_s).save
  end
end

task default: [:test, :rubocop]
