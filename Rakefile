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

task default: [:test, :rubocop]
