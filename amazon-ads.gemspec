# frozen_string_literal: true

require_relative "lib/amazon_ads/version"

Gem::Specification.new do |spec|
  spec.name = "amazon-ads"
  spec.version = AmazonAds::VERSION
  spec.authors = ["Hakan Ensari"]
  spec.email = ["hakanensari@gmail.com"]

  spec.summary = "Amazon Ads API client for Ruby"
  spec.homepage = "https://github.com/lineofflight/amazon-ads-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/amazon_ads/**/*.rb", "sig/generated/amazon_ads/**/*.rbs"]
    .append("lib/amazon_ads.rb", "sig/generated/amazon_ads.rbs", "LICENSE.txt", "README.md")
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("http", "~> 5.3")
  spec.add_dependency("zeitwerk", "~> 2.6")
end
