# frozen_string_literal: true

# rbs_inline: enabled

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("api" => "API")
loader.collapse("#{__dir__}/sponsor/apis")
loader.ignore("#{__dir__}/generator")
loader.setup

# Amazon Ads API client for Ruby
module Sponsor
end
