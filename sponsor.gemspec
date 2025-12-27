# frozen_string_literal: true

require_relative "lib/sponsor/version"

Gem::Specification.new do |spec|
  spec.name = "sponsor"
  spec.version = Sponsor::VERSION
  spec.authors = ["Hakan Ensari"]
  spec.email = ["hakanensari@gmail.com"]

  spec.summary = "Amazon Ads API in Ruby"
  spec.homepage = "https://github.com/lineofflight/sponsor"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(["git", "ls-files", "-z"], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?("bin/", "Gemfile", ".gitignore", "test/", ".github/", ".rubocop.yml")
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
