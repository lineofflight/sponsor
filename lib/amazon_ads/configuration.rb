# frozen_string_literal: true

# rbs_inline: enabled

module AmazonAds
  # Configuration for the AmazonAds library.
  # Centralizes settings for authentication and API access.
  class Configuration
    attr_accessor :client_id #: String?
    attr_accessor :client_secret #: String?
    attr_accessor :refresh_token #: String?
    attr_accessor :region #: Symbol
    attr_accessor :profile_id #: String?

    #: () -> void
    def initialize
      @client_id = ENV["AMAZON_ADS_CLIENT_ID"]
      @client_secret = ENV["AMAZON_ADS_CLIENT_SECRET"]
      @refresh_token = ENV["AMAZON_ADS_REFRESH_TOKEN"]
      @region = :na
      @profile_id = nil
    end

    # Builds an LWA instance from the configuration.
    #: () -> LWA
    def lwa
      LWA.new(
        client_id: client_id || raise(ArgumentError, "client_id is required"),
        client_secret: client_secret || raise(ArgumentError, "client_secret is required"),
        refresh_token: refresh_token || raise(ArgumentError, "refresh_token is required"),
      )
    end
  end
end
