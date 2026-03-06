# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "dotenv/load"

ENV["AMAZON_ADS_CLIENT_ID"] ||= "dummy"
ENV["AMAZON_ADS_CLIENT_SECRET"] ||= "dummy"

require "amazon_ads"

require "minitest/autorun"

require_relative "support/recordable"
require_relative "support/feature_helpers"
