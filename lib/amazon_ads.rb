# frozen_string_literal: true

# rbs_inline: enabled

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("api" => "API", "lwa" => "LWA")
loader.collapse("#{__dir__}/amazon_ads/apis")
loader.ignore("#{__dir__}/generator")
loader.ignore("#{__dir__}/amazon_ads/errors.rb")
loader.setup

require_relative "amazon_ads/errors"

# Amazon Ads API client for Ruby
module AmazonAds
  class << self
    # Returns the global configuration object.
    #: () -> Configuration
    def configuration
      @configuration ||= Configuration.new
    end

    # Configures the AmazonAds library.
    #: () { (Configuration) -> void } -> void
    def configure
      yield(configuration)
    end

    # Resets the configuration to defaults.
    #: () -> void
    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
